defmodule Trabant.Amperes do
  require Logger

  def init(file) do
    CubDB.delete(:db, file)
  end

  def get(ampere) do
    CubDB.get(:db, ampere)
  end

  def put(ampere, what) do
    CubDB.put(:db, ampere, what)
  end
end
