module CarrierWave
  module PostgresqlTable
    class RackApp
      READ_CHUNK_SIZE = 16384

      def call(env)
        request = Rack::Request.new(env)

        file = CarrierWave::Storage::PostgresqlTable::File.new(request.path.sub(/^\//, ""))

        headers = {
          "Last-Modified" => file.last_modified.httpdate,
          "Content-Type" => file.content_type,
          "Content-Disposition" => "inline",
        }

        if(request.params["download"] == "true")
          headers["Content-Disposition"] = "attachment; filename=#{file.filename}"
        end

        body = Enumerator.new do |response_body|
          while(chunk = file.read(READ_CHUNK_SIZE)) do
            response_body << chunk
          end
        end

        [200, headers, body]
      end
    end
  end
end
