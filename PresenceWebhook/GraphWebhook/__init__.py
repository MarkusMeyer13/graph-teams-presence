import logging
import os
import azure.functions as func
import json

def main(req: func.HttpRequest, msgOut: func.Out[str], context: func.Context)-> func.HttpResponse: 
    
    thisdict = {
    "brand": "Ford",
    "model": "Mustang",
    "year": 1964
    }
    properties = {'custom_dimensions': {'key_1': 'value_1', 'key_2': 'value_2'}}
    logging.Logger.info('action', extra=properties)
    logging.Logger.info('Python HTTP trigger function processed a request.', extra=thisdict)
    validationToken = req.params.get('validationToken')
    # req_body = req.get_json()

    logging.info(validationToken)
    logging.info(req.url)

    body = req.get_body()
    logging.info(len(body))
    if len(body) > 0:
        logging.info(body.decode("utf-8"))
        msgOut.set(body.decode("utf-8"))
    else:
        logging.info("Body is empty")

    return func.HttpResponse(validationToken)