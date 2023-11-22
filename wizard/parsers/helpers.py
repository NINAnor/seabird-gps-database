def stream_starts_with(stream, text):
    position = stream.tell()
    chunk = stream.read(len(text))
    stream.seek(position)
    return chunk == text


def read_csv(data, separator=",", newline="\n", trailing=""):
    for line in data.split(newline):
        if not line:
            break  # EOF?
        if len(trailing) > 0:
            assert line.endswith(trailing)
            line = line[: -len(trailing)]
        yield line.split(separator)
