defmodule Bumblebee.Text.GptNeoXTokenizer do
  @moduledoc """
  GPT-NeoX tokenizer.
  """

  @behaviour Bumblebee.Text.Conversation

  import Bumblebee.Shared

  tokenizer_impl(
    special_tokens: %{
      unk: "<|endoftext|>",
      bos: "<|endoftext|>",
      eos: "<|endoftext|>",
      # GPT-NeoX doesn't originally have a pad token, however when necessary
      # we pad with the EOS token
      pad: "<|endoftext|>"
    }
  )

  @impl true
  def conversation_history_to_text(tokenizer, history) do
    eos_token = tokenizer.special_tokens.eos

    history
    |> Enum.reverse()
    |> Enum.map_join(&(elem(&1, 1) <> eos_token))
  end
end
