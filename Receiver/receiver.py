from azure.servicebus import ServiceBusClient, ServiceBusMessage
from configparser import ConfigParser
import asyncio

# CONNECTION_STR = "<NAMESPACE CONNECTION STRING>"
# TOPIC_NAME = "<TOPIC NAME>"
# SUBSCRIPTION_NAME = "<SUBSCRIPTION NAME>"

#Get the configparser object
config_object = ConfigParser()
config_object.read("config.ini")
service_bus_info = config_object["SERVICEBUS"]

#Read config.ini file
config_object = ConfigParser()
config_object.read("config.ini")

servicebus_client = ServiceBusClient.from_connection_string(conn_str=service_bus_info["serviceBusConnection"], logging_enable=True)

# with servicebus_client:
#     receiver = servicebus_client.get_subscription_receiver(topic_name=service_bus_info["topic_name"], subscription_name=service_bus_info["subscription_name"], max_wait_time=5)
#     with receiver:
#         for msg in receiver:
#             print("Received: " + str(msg))
#             receiver.complete_message(msg)

async def myCoroutine():
    while True:
        print("My Coroutine")
        with servicebus_client:
            receiver = servicebus_client.get_subscription_receiver(topic_name=service_bus_info["topic_name"], subscription_name=service_bus_info["subscription_name"], max_wait_time=5)
            with receiver:
                for msg in receiver:
                    print("Received: " + str(msg))
                    receiver.complete_message(msg)

# Main Method in Python which implements the infinite loop so that the server keeps running.
if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    # loop.create_task(amain(loop=loop))
    try:
        asyncio.ensure_future(myCoroutine())
        loop.run_forever()

    except KeyboardInterrupt:
        pass

# loop = asyncio.get_event_loop()
# try:
#     loop.run_until_complete(myCoroutine())
# finally:
#     loop.close()