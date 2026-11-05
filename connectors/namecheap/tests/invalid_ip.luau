-- Namecheap requires an IPv4 ClientIp; an IPv6 or malformed setting fails clearly before any request.
return {
	scenario = {publisher = {}, auth_method = "token", auth_config = {token = "fixture-key"},
		config = {api_host = "api.sandbox.namecheap.com", username = "ada", client_ip = "2001:db8::7"}},
	configure = function()
		calls = 0
		http = {request = function(req)
			calls += 1
			return fixture.operation({statusCode = 200, headers = {}, body = fixture.reader("")})
		end}
	end,
	run = function(namecheap)
		for _, call in {
			function() namecheap.listDomains() end,
			function() namecheap.getDnsRecords("example.com") end,
		} do
			local ok, err = pcall(call)
			assert(not ok and string.find(tostring(err), "must be an IPv4 address", 1, true), tostring(err))
		end
		assert(calls == 0, "a bad IP setting reached the network")
	end,
}
