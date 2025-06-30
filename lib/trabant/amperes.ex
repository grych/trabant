defmodule Trabant.Amperes do
  require Logger
  def init(file) do
    # file = String.to_atom(file)
    # :dets.open_file(file, [type: :set])
    # :dets.close(file)
    # {:ok, db} = CubDB.start_link()
    # Logger.debug(inspect(db))
    CubDB.delete(:db, file)
  end

  def get(file) do
    CubDB.get(:db, file)
  end

  def put(file, what) do
    CubDB.put(:db, file, what)
  end
end
