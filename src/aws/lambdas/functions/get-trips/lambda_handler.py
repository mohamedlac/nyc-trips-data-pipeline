import boto3
import botocore
import requests
import logging
import os
from datetime import datetime, timezone


URL_ENDPOINT = os.getenv('URL_ENDPOINT')
RAW_BUCKET_NAME = os.getenv('RAW_BUCKET_NAME')

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def get_trips(url):
    """
    Fetch parquet file content of the trips data.

    :param url: parquet file url
    :return:
    """
    try:

        logger.info(f"Fetching data from URL: {url}")
        response = requests.get(url)
        response.raise_for_status()

        return response

    except requests.exceptions.RequestException as e:

        logger.error(f"Failed to fetch data from URL: {url}. Error: {str(e)}")
        raise


def upload_to_s3(bucket, key, data):
    """
    Upload the parquet file content to the s3 raw bucket.

    :param bucket: Name of the raw bucket.
    :param key: Key of the parquet file to upload
    :param data: Trips data to upload.

    :return:
    """

    s3_client = boto3.client('s3')
    try:
        s3_client.put_object(
            Bucket=bucket,
            Key=key,
            Body=data
        )
        logger.info("Successfully uploaded data to S3")

    except boto3.exceptions.S3UploadFailedError as e:
        logger.error(f"Failed to upload data to S3 bucket: {bucket}, key: {key}. Error: {str(e)}")
        raise

    except Exception as e:
        logger.error(f"An unexpected error occurred while uploading data to S3. Error: {str(e)}")
        raise


def handle_historical_data(start_date, end_date):
    pass


def handle_monthly_data(taxi_type, year, month):
    """
    Fetch Trips data for a specific taxi_type, year and month.

    :param taxi_type: Taxi type of the monthly trips to be fetched.
    :param year: Year of the trips data.
    :param month: Month of the trips data.

    :return:
    """

    url = URL_ENDPOINT+"/"+"{taxi_type}_tripdata_{year}-{month}.parquet"
    url = url.format(taxi_type=taxi_type, year=year, month=month)

    response = get_trips(url)

    key = "landing/{taxi_type}_trips_data_{year}_{month}.parquet"
    key = key.format(taxi_type=taxi_type, year=year, month=month)

    upload_to_s3(
        bucket=RAW_BUCKET_NAME,
        key=key,
        data=response.content
    )


def lambda_handler(event, context):
    """

    :param event:
    :param context:
    :return:
    """

    if event.get("action") == "retrieve_historical_data":
        logger.info("Event Action is set to retrieve_historical_data")
        start_date = event['detail'].get('start_date')
        end_date = event['detail'].get('end_date')

        if not (start_date and end_date):
            logger.error("Invalid event format: start_date and end_date are required for historical data retrieval.")
            raise ValueError(
                "Invalid event format: start_date and end_date are required for historical data retrieval.")

        handle_historical_data(start_date, end_date)

    else:
        # current_date = #datetime.now(timezone.utc)
        current_month = "03"  # current_date.month
        current_year = "2022"  # current_date.year
        handle_monthly_data(taxi_type="yellow",  year=current_year, month=current_month)
