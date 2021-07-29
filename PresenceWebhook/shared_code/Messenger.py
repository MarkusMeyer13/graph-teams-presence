from azure.servicebus import ServiceBusClient, ServiceBusMessage

class Messenger:
  def __init__(self, connection_string, queue_name):
    self.queue_name = queue_name
    self.connection_string = connection_string
    self.servicebus_client = ServiceBusClient.from_connection_string(conn_str=self.connection_string, logging_enable=True)

  def send_single_message(self, message):
      # create a Service Bus message
      message = ServiceBusMessage(message)
      # message.scheduled_enqueue_time_utc
      # send the message to the queue
      with self.servicebus_client:
            # get a Queue Sender object to send messages to the queue
            self.sender = self.servicebus_client.get_queue_sender(queue_name=self.queue_name)
            self.sender.send_messages(message)
      print("Sent a single message")      