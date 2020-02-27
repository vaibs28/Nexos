defmodule Challenge do

  def parseTextFile do
    db_props = %{protocol: "http", hostname: "localhost", database: "test", port: 5984, user: "admin", password: "mohansahay"}
    #list of field lengths
    fieldIndex = [0,16,22,34,44,50,56,60,64,76]
    fieldLengths = [16,6,12,10,6,6,4,4,6,12]
    #list of field names
    fieldsList = ["Account_Number","Code","Amount", "Datetime","Trace_number","Time","Date","Capture_date","Company_id","Reference_num"]
    #fieldMap = %{"Account_Number": 16, "Code": 6, "Amount": 12, "Datetime": 10, "Trace_number": 6, "Time": 6, "Date": 4, "Capture_date": 4, "Company_id": 6, "Reference_num": 12}
    #reads the file content using the delimiters \n for a new line
    {:ok,fileContents} = File.read("/Users/vaibhav/Documents/nexos/challenge/lib/test.txt");
    #splitting the contents on newline and storing in a list
    lines = fileContents |> String.split("\n")
    #iterate over each line
    digitList = ["0","1","2","3","4","5","6","7","8","9"]
    Enum.each(lines, fn x ->
      first = String.first(x)
      if Enum.member?(digitList,first) do
      #get the list of values
      combinedList = Enum.zip([fieldsList , fieldIndex, fieldLengths])
      map = Enum.reduce( combinedList,  %{} , fn key , map ->
        start = elem(key, 1)
        size = elem(key, 2)
        field = elem(key, 0)
        value = String.slice(x , start , size)
        Map.put(map, field, value)
      end)
      list = getFields(x , fieldIndex , fieldLengths)
      IO.puts("Printing the values of the fields stored in the list")
      IO.inspect(list)
      IO.puts("Printing the key-value pair stored in map")
      IO.inspect(map)
      #{:ok, server} = :couchdb.server_record("http://localhost:5984", [])
      #{:ok, info} = :couchdb_server.info(server)
      #{:ok, database} = :couchdb.database_record(server , "nexos-test")
      #:couchdb_documents.save(database, map)
      primaryKey = List.first(list)
      #writing to couchdb
      Couchdb.Connector.Storage.storage_up(db_props)
      Couchdb.Connector.create(db_props,map,primaryKey)
    end
    end)
  end

  @spec getFields(any, [any], any) :: [any]
  def getFields(line, indices, lengths) do
    list = []
    list = for i <- 0..length(indices)-1 do
      {start, _temp} = List.pop_at(indices , i)
      {size, _temp} =  List.pop_at(lengths , i)
      fieldValue = String.slice(line , start , size)  #gets the substring from start to start+size
      _list = list ++ fieldValue                      #appending to the end of the list
    end
    list
  end

end
