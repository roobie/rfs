local lapis = require('lapis')
local helpers = require('lapis.application')
local inspect = require('inspect')
local lfs = require('lfs')

local app = lapis.Application()

-- function app:default_route ()
-- end
-- function app:handle_404()
-- end

local root = 'test_files/'

app:match('/(*)', helpers.respond_to {
            GET = function (ctx)
              local path = root..(ctx.params.splat or '')
              local attrs = lfs.attributes(path)
              if attrs == nil then
                return {status=404}
              end
              local isdir = attrs.mode == 'directory'

              if isdir then
                local file_list = {}
                for file in lfs.dir(path) do
                  local attributes = lfs.attributes(root..file)
                  file_list[#file_list+1] = {
                    name = file;
                    attributes = attributes;
                  }
                end
                return {json=file_list}
              else
                ctx:write {
                  status = 200;
                  content_type = "text";
                }

                local contents = {}
                for line in io.lines(path) do
                  contents[#contents+1] = line
                end
                ctx:write(table.concat(contents))
              end
            end
})

return app
