import logging
import os
import azure.functions as func
import json

def main(req: func.HttpRequest, msgOut: func.Out[str], context: func.Context)-> func.HttpResponse: 
    
    logging.info('Python HTTP trigger function processed a request.')
    validationToken = req.params.get('validationToken')
    # req_body = req.get_json()
    # input_msg = json.dumps(req_body)
    logging.info(validationToken)
    logging.info(req.url)

    body = req.get_body()
    logging.info(body.decode("utf-8"))

    msgOut.set(validationToken)
    return func.HttpResponse(validationToken)