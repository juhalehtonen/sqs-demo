defmodule SQSDemo do
  @moduledoc """
  Documentation for SQSDemo.

  AWS Credentials need to be supplied either as env vars
  AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY, or in the
  producer configuration.
  """
  use Broadway
  alias Broadway.Message

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {BroadwaySQS.Producer,
                 queue_url: "https://sqs.eu-north-1.amazonaws.com/007549396494/demo-queue",
                 config: [
                   region: "eu-north-1"
                 ]
                },
        concurrency: 30
      ],
      processors: [
        default: [
          concurrency: 30
        ]
      ],
      batchers: [
        default: [
          batch_size: 10,
          batch_timeout: 2000
        ]
      ]
    )
  end

  #...helpers...

  @doc """
  Small helper function to update data in the processors.
  Just used for demo, don't do this at home.
  """
  def get_only_query(message) do
    response = Jason.decode!(message.data)
    response["query"]
  end

  # ...callbacks...

  @impl true
  @doc """
  Invoked by processors for each message.
  Must return the (potentially) updated Broadway.Message struct.

  This is the place to do any kind of processing with the incoming message,
  e.g., transform the data into another data structure, call specific business
  logic to do calculations. Basically, any CPU bounded task that runs against
  a single message should be processed here.
  """
  def handle_message(_processor, %Message{data: data} = message, _context) do
    message
    |> Message.update_data(fn message -> message end)
  end

  @impl true
  @doc """
  Batch processors (spawned by Batchers) invoke this for each batch.
  Send batch of successful messages as ACKs to SQS. This tells SQS
  that this list of messages were successfully processed.

  It must return an updated list of messages. All messages received must be
  returned, otherwise an error will be logged. All messages after this step
  will be acknowledged acccording to their status.

  In case of errors in this callback, the error will be logged and the whole
  batch will be failed. This callback also traps exits, so failures due to
  broken links between processes do not automatically cascade.
  """
  def handle_batch(_batcher_type, messages, _batch_info, _context) do
    list = messages |> Enum.map(fn message -> get_only_query(message) end)
    IO.inspect(list, label: "Got batch of finished jobs from processors, sending ACKs to SQS as a batch.")
    messages
  end
end
