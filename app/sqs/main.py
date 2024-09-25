import logging
import sys
import boto3
import os

from botocore.exceptions import ClientError

sqs = boto3.resource('sqs')
logger = logging.getLogger(__name__)
FORMAT = "[INFO: %(filename)s:%(lineno)s:%(funcName)s]::%(message)s"
logging.basicConfig(format=FORMAT)
logger.setLevel(logging.INFO)

def get_queue(name):
    try:
        queue = sqs.get_queue_by_name(QueueName=name)
        logger.info("Got queue '%s' with URL=%s", name, queue.url)
    except ClientError as e:
        logger.exception("Something went wrong.")
        raise e
    else:
        return queue
    

def send_message(queue, body, attributes):
    if not attributes:
        attributes = {}

    try:
        response = queue.send_message(MessageBody=body, MessageAttributes=attributes)
        logger.info("Sent message: '%s'", body)
    except ClientError as e:
        logger.exception("Failed: %s", body)
        raise e
    else:
        return response
    
def lambda_handler(event, message):
    queue_name = os.environ['QUEUE_NAME']
    message = os.environ['QUEUE_MESSAGE']
    try:
        queue = get_queue(queue_name)
        response = send_message(queue, message, attributes=None)
    except ClientError as e:
        logger.exception("Fuck.")
        raise e
    else:
        return response
    
lambda_handler("messages_queue", "foo")