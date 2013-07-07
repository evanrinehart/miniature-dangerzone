command_table = {
  parse = require('commands/parse'),
  kill = require('commands/kill'),
  follow = nil,
  group = nil,
  ungroup = nil,
  flee = nil,
  resign = nil,
  move = require('commands/move'),
  take = require('commands/take'),
  look = require('commands/look'),
  examine = nil,
  inv = require('commands/inv'),
  drop = require('commands/drop'),
  give = nil,
  wear = nil,
  remove = nil,
  drink = nil,
  eat = nil,
  read = nil,
  put = nil,
  open = nil,
  close = nil,
  use = nil,
  help = require('commands/help'),
  quit = require('commands/quit'),
  say = require('commands/say'),
  tell = require('commands/tell'),
  gossip = require('commands/gossip'),
  shout = require('commands/shout'),
  reply = require('commands/reply'),
  lock = nil,
  unlock = nil,
  pay = nil,
  donate = nil,
  checkpoint = require('commands/checkpoint'),
  dig = nil,
  stats = require('commands/stats')
}
