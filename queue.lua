--[[
a sorted queue data structure

in this data structure you have two operations
1. take from the beginning of the queue
2. insert a value in the sorted position

it is implemented as a mutable linked list with a dummy node
--]]


local function mk_node(x, link)
  return {value = x, next = link}
end

local function each(head, f)
  local i = 1
  local node = head.next
  while node do
    f(node.value, i)
    node = node.next
    i = i + 1
  end
end

local function search(node, x, compare)
  if node.next == nil then
    return node
  elseif compare(x, node.next.value) > 0 then
    return search(node.next, x, compare)
  else
    return node
  end
end

local function is_empty(head)
  return function()
    return head.next == nil
  end
end

local function take(head)
  return function()
    if is_empty(head)() then
      return nil
    else
      local x = head.next.value
      head.next = head.next.next
      return x
    end
  end
end

local function peek(head)
  return function()
    if head.next == nil then
      return nil
    else
      return head.next.value
    end
  end
end

local function insert(head, compare)
  return function(x)
    if head.next == nil then
      head.next = mk_node(x, nil)
    else
      local parent = search(head, x, compare)
      parent.next = mk_node(x, parent.next)
    end
  end
end

local function to_table(head)
  return function()
    local accum = {}

    each(head, function(x, i)
      accum[i] = x
    end)

    return accum
  end
end

local function debug(head, show)
  return function()
    if head.next == nil then
      print("(empty queue)")
    else
      each(head, function(x, i) print(show(x)) end)
    end
  end
end

local function remove(head, get_id)
  return function(id)
    -- TODO
  end
end

return {
  new = function(compare, get_id, show)
    local head = mk_node(nil, nil)

    return {
      is_empty = is_empty(head),
      take = take(head),
      insert = insert(head, compare),
      to_table = to_table(head),
      remove = remove(head, get_id),
      peek = peek(head),
      debug = debug(head, show)
    }
  end
}
