import logging
import os
import azure.functions as func

def main(req: func.HttpRequest, msgOut: func.Out[str], context: func.Context)-> func.HttpResponse: 
    
    logging.info('Python HTTP trigger function processed a request.')
    
    input_msg = req.params.get('message')
    logging.info(input_msg)

    my_app_setting_value = os.environ["ServiceBusConnection"]
    logging.info(my_app_setting_value)

    msgOut.set(input_msg)
    return func.HttpResponse("OK")