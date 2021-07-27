import logging
import os
import azure.functions as func
import json

def main(req: func.HttpRequest, msgOut: func.Out[str], context: func.Context)-> func.HttpResponse: 
    
    logging.info('Python HTTP trigger function processed a request.')
    req_body = req.get_json()
    input_msg = json.dumps(req_body)
    # logging.info(input_msg)


    msgOut.set(input_msg)
    return func.HttpResponse("OK")