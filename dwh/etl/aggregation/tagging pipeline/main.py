import os
import pymongo
import pandas as pd
import json
import logging
from bson import ObjectId
from dotenv import load_dotenv
from preprocess import preprocess_data
from generate import generate_attributes
from postprocess import postprocess_data


def connect_to_mongodb() -> pymongo.MongoClient:
    """
    Connect to MongoDB and return the client object.

    :return: MongoDB client object
    """
    client = pymongo.MongoClient(os.getenv("MONGO_CLIENT_URI"))
    return client


def get_total_profile_count(mongo_client, mongo_collection_name):
    """
    Get the total number of profiles that have experiences or education data.

    :param mongo_client: MongoDB client object
    :param mongo_collection_name: Name of the MongoDB collection

    :return: Total number of profiles
    """
    db = mongo_client['raw_data']
    collection = db[mongo_collection_name]

    # Query to find profiles with experiences or education data
    query = {
        "$or": [
            {"experiences": {"$exists": True, "$ne": []}},
            {"education": {"$exists": True, "$ne": []}}
        ]
    }

    return collection.count_documents(query)


def load_profiles(mongo_client, mongo_collection_name, skip, limit):
    """
    Load profiles that have experiences or education data from the MongoDB collection.

    :param mongo_client: MongoDB client object
    :param mongo_collection_name: Name of the MongoDB collection
    :param skip: Number of profiles to skip
    :param limit: Maximum number of profiles to load

    :return: DataFrame containing the loaded profiles
    """
    db = mongo_client['raw_data']
    collection = db[mongo_collection_name]

    # Query to find profiles with experiences or education data
    query = {
        "$or": [
            {"experiences": {"$exists": True, "$ne": []}},
            {"education": {"$exists": True, "$ne": []}}
        ]
    }

    # Projection to include only the necessary fields
    projection = {
        "_id": 1,
        "experiences": 1,
        "education": 1
    }

    # Load profiles using the query, projection, skip, and limit
    profiles = list(collection.find(query, projection).skip(skip).limit(limit))
    return pd.DataFrame(profiles)


def save_results(client, mongo_collection_name, df):
    """
    Save the processed results to the MongoDB collection.

    :param client: MongoDB client object
    :param mongo_collection_name: Name of the MongoDB collection
    :param df: DataFrame containing the processed results
    """
    db = client['processed_data']
    collection = db[mongo_collection_name]
    results = df.to_dict('records')

    for result in results:
        # Ensure _id is an ObjectId
        if not isinstance(result['_id'], ObjectId):
            result['_id'] = ObjectId(result['_id'])

        # Insert the document, or update if it already exists
        collection.replace_one({'_id': result['_id']}, result, upsert=True)

    logging.info(f"Saved {len(results)} results to the database.")


def process_batch(client, mongo_collection_name, skip, limit, experience_prompt, education_prompt):
    """
    Process a batch of profiles from the MongoDB collection.

    :param client: MongoDB client object
    :param mongo_collection_name: Name of the MongoDB collection
    :param skip: Number of profiles to skip
    :param limit: Maximum number of profiles to process
    :param experience_prompt: System prompt for experiences
    :param education_prompt: System prompt for education
    """
    df = load_profiles(client, mongo_collection_name, skip, limit)
    logging.info(f"Loaded {len(df)} profiles (batch starting at {skip})")

    df = preprocess_data(df, experience_prompt, education_prompt)
    df = generate_attributes(df)
    df = postprocess_data(df)

    save_results(client, mongo_collection_name, df)
    logging.info(f"Batch processed and saved (profiles {skip} to {skip + len(df) - 1})")


# Main function
def main():
    # Set logging configuration
    logging.basicConfig(level=logging.INFO)

    # Load environment variables
    load_dotenv()

    # Connect to MongoDB
    client = connect_to_mongodb()

    # Define constants
    mongo_collection_name = 'KGL_LIN_PRF_USA'
    batch_size = 100

    # Load prompts
    with open("prompts.json") as f:
        prompts = json.load(f)
        experience_prompt = prompts["experience"]
        education_prompt = prompts["education"]

    try:
        # Get total number of profiles
        total_profiles = get_total_profile_count(client, mongo_collection_name)
        logging.info(f"Total profiles to process: {total_profiles}")

        # Process profiles in batches
        for skip in range(0, total_profiles, batch_size):
            process_batch(
                client,
                mongo_collection_name,
                skip,
                batch_size,
                experience_prompt,
                education_prompt
            )

        logging.info("All batches processed successfully")

    finally:
        client.close()


# Run the main function
if __name__ == "__main__":
    main()
