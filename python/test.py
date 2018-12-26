#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import lupa
from lupa import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)

func = lua.eval('''
...     function(items)
...         for a, b, c, d in python.iterex(items) do
...             return {a == python.none, a == nil,   -->  a == python.none
...                     b == python.none, b == nil,   -->  b == nil
...                     c == python.none, c == nil,   -->  c == nil
...                     d == python.none, d == nil}   -->  d == nil ...
...         end
...     end
... ''')

items = [(None, None, None, None)]
print(list(func(items).values()))

items = [(None, None)]
print(list(func(items).values()))