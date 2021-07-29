import logging
import os
import azure.functions as func
import json

from opencensus.ext.azure.trace_exporter import AzureExporter
from opencensus.ext.azure.log_exporter import AzureLogHandler
from opencensus.trace import config_integration
from opencensus.trace.samplers import ProbabilitySampler
from opencensus.trace.tracer import Tracer
from opencensus.trace import execution_context
from opencensus.trace.propagation.trace_context_http_header_format import TraceContextPropagator

logger = logging.getLogger(__name__)
if logger.hasHandlers():
    logger.handlers.clear()

config_integration.trace_integrations(['logging'])
instrucment_key = os.getenv('APPINSIGHTS_INSTRUMENTATIONKEY')



exporter = AzureExporter(connection_string=f'InstrumentationKey={instrucment_key}')
handler = AzureLogHandler(connection_string=f'InstrumentationKey={instrucment_key}')

logger = logging.getLogger(__name__)
logger.addHandler(handler)

def main(req: func.HttpRequest, msgOut: func.Out[str], context: func.Context)-> func.HttpResponse: 
    span_context = TraceContextPropagator().from_headers({
        "traceparent": context.trace_context.Traceparent,
        "tracestate": context.trace_context.Tracestate
    })
    tracer = Tracer(
        span_context=span_context,
        exporter=exporter,
        sampler=ProbabilitySampler(1.0)
    )
    execution_context.set_opencensus_tracer(tracer)

    with tracer.span("custom_dimensions_span"):
        properties = {'custom_dimensions': {'req.url': req.url, 'invocation_id': context.invocation_id, 'function_name': context.function_name}}
        logger.info('Start', extra=properties)

    validationToken = req.params.get('validationToken')
    # req_body = req.get_json()

    logging.info(validationToken)
    logging.info(req.url)
    properties["validationToken"] = validationToken
    body = req.get_body()
    logging.info(len(body))
    if len(body) > 0:
        requestBody = body.decode("utf-8") 
        logging.info(requestBody)
        msgOut.set(requestBody)
        properties["requestBody"] = requestBody
    else:
        logging.info("Body is empty")
        with tracer.span("custom_dimensions_span"):
            properties = properties
            logging.info("No body", extra=properties)        

    with tracer.span("custom_dimensions_span"):
        properties = properties
        logging.info("Finish", extra=properties)

    return func.HttpResponse(validationToken)