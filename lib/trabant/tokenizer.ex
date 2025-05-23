defmodule Trabant.Tokenizer do

  @non_closing_tags ~w{
    area base br col command embed hr img input keygen link meta param source track wbr
    area/ base/ br/ col/ command/ embed/ hr/ img/ input/ keygen/ link/ meta/ param/ source/ track/
    wbr/
  }

  defstruct tokenized: []

  @doc """
  Simple html tokenizer. Works with nested lists.

      iex> tokenize("<html> <body >some<b> anything</b></body ></html>")
      %Trabant.Tokenizer{tokenized: [{:tag, "html"}, {:text, " "}, {:tag, "body "}, {:text, "some"},
      {:tag, "b"}, {:text, " anything"},
      {:tag, "/b"}, {:tag, "/body "}, {:tag, "/html"}, {:text, ""}]}

      iex> tokenize("some")
      %Trabant.Tokenizer{tokenized: [{:text, "some"}]}

      iex> tokenize(["some"])
      [%Trabant.Tokenizer{tokenized: [{:text, "some"}]}]

      iex> tokenize("")
      %Trabant.Tokenizer{tokenized: [{:text, ""}]}

      iex> tokenize([""])
      [%Trabant.Tokenizer{tokenized: [{:text, ""}]}]

      iex> tokenize("<!-- comment -->")
      %Trabant.Tokenizer{tokenized: [comment: "-- comment --", text: ""]}

      iex> tokenize("<!--comment--> text")
      %Trabant.Tokenizer{tokenized: [comment: "--comment--", text: " text"]}

      iex> tokenize("<tag> and more")
      %Trabant.Tokenizer{tokenized: [{:tag, "tag"}, {:text, " and more"}]}

      iex> tokenize("<tag> <naked tag")
      %Trabant.Tokenizer{tokenized: [{:tag, "tag"}, {:text, " "}, {:naked, "naked tag"}]}

      iex> tokenize(["<tag a/> <naked tag"])
      [%Trabant.Tokenizer{tokenized: [{:tag, "tag a/"}, {:text, " "}, {:naked, "naked tag"}]}]

      iex> tokenize(["other", "<tag a> <naked tag"])
      [%Trabant.Tokenizer{tokenized: [{:text, "other"}]},
      %Trabant.Tokenizer{tokenized: [{:tag, "tag a"}, {:text, " "}, {:naked, "naked tag"}]}]

      iex> tokenize(["other", :atom, "<tag a/> <naked tag"])
      [%Trabant.Tokenizer{tokenized: [{:text, "other"}]}, :atom,
      %Trabant.Tokenizer{tokenized: [{:tag, "tag a/"}, {:text, " "}, {:naked, "naked tag"}]}]

      iex> tokenize(["<tag", :atom, ">"])
      [%Trabant.Tokenizer{tokenized: [naked: "tag"]},
      :atom, %Trabant.Tokenizer{tokenized: [{:text, ">"}]}]

      iex> tokenize [do: {:->, [line: 3], [["set in the commander"], "commander"]}]
      [
        do: {:->, [line: 3],
        [
          [%Trabant.Tokenizer{tokenized: [text: "set in the commander"]}],
          %Trabant.Tokenizer{tokenized: [text: "commander"]}
        ]}
      ]

      iex> tokenize("<!-- Comment -->")
      %Trabant.Tokenizer{tokenized: [comment: "-- Comment --", text: ""]}

      iex> tokenize("<!DOCTYPE html>")
      %Trabant.Tokenizer{tokenized: [comment: "DOCTYPE html", text: ""]}
  """
  def tokenize(string) when is_binary(string) do
    %Trabant.Tokenizer{tokenized: tokenize_string(string)}
  end

  def tokenize({code, meta, args}) do
    {code, meta, tokenize(args)}
  end

  @block ~w(do end catch rescue after else)a
  def tokenize({atom, args}) when atom in @block do
    {atom, tokenize(args)}
  end

  def tokenize([head | tail]) do
    [tokenize(head) | tokenize(tail)]
  end

  def tokenize(other) do
    other
  end

  defp tokenize_string("<" <> rest) do
    case String.split(rest, ">", parts: 2) do
      # naked tag can be only at the end
      [tag] ->
        [{:naked, trim_and_lower(tag)}]

      ["!" <> comment | tail] ->
        [{:comment, comment} | tokenize_string(Enum.join(tail))]

      [tag | tail] ->
        tag = trim_and_lower(tag)

        case tag_name(tag) do
          t when t in @non_closing_tags ->
            [{:non_closing_tag, tag} | tokenize_string(Enum.join(tail))]

          _ ->
            [{:tag, tag} | tokenize_string(Enum.join(tail))]
        end
    end
  end

  defp tokenize_string(string) when is_binary(string) do
    case String.split(string, "<", parts: 2) do
      [no_more_tags] -> [{:text, no_more_tags}]
      [text, rest] -> [{:text, text} | tokenize_string("<" <> rest)]
    end
  end

  defp trim_and_lower(string) do
    string |> String.trim_leading() |> lowercase_tag_name()
  end

  defp lowercase_tag_name(string) do
    tag = tag_name(string)
    String.replace(string, ~r/^\/?#{tag}/, String.downcase(tag))
  end

  defp tag_name(tag) do
    tag |> String.split(~r/\s/) |> List.first()
  end

end
