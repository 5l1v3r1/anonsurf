import httpclient

proc getCurrentIP*(): string =
  # flag -d:ssl
  let getIP = newHttpClient()
  return getIP.getContent("https://start.parrotsec.org/ip/")

