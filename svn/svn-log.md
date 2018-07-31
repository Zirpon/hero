# svn log

svn log ./battlefield.lua@3771 -diff
svn log ./battlefield.lua@3771 -v
svn log ./battlefield.lua@3771 -q
svn log -r BASE:HEAD ./battlefield.lua --diff
svn log --search "ddd" --search-and "xxx"
svn log -r COMMITTED ./battlefield.lua

---