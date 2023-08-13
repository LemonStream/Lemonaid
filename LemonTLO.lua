local mq = require('mq')

local counterType = mq.DataType.new('LemonType', {
    Members = {
        Value = function(_, counter)--mq.TLO.CounterDemo.Value()
            return 'int', counter.value
        end,

        Name = function(_, counter) --mq.TLO.CounterDemo.Name()
            return 'string', counter.name
        end
    },

    Methods = {
        Reset = function(_, counter)
            counter.value = 0
        end,
        Increment = function(value, counter)
            counter.value = counter.value + tonumber(value)
        end,
        Set = function(value, counter)
            counter.value = value
        end
    }
})

function counterType.ToString(counter)
    return string.format('Counter %s: %d', counter.name, counter.value)
end

local allCounters = {
    default = { name = 'default', value = 0 },
    default = { name = 'default', value = 0 }
}
local function CounterDemo(index) --mq.TLO.CounterDemo(index)()
    printf("index is %s",index)
    local name = index
    if index == nil or #index == 0 then
        name = 'default'
    end

    local counter = allCounters[name]
    if counter ~= nil then
        return counterType, counter
    else
        allCounters[name] = {name = name, value = 69} --If the index doesn't exist, create it with default values and return it
        return counterType, allCounters[name]
    end
end

local function AllCounters(_)
    return 'table', allCounters
end

mq.AddTopLevelObject('CounterDemo', CounterDemo)
mq.AddTopLevelObject('AllCountersDemo', AllCounters)

while true do
    mq.delay(1000)
end
--[[
> /echo ${CounterDemo}
Counter default: 0
> /echo ${CounterDemo[test]}
Counter test: 0
> /invoke ${CounterDemo[test].Increment[3]}
> /echo ${CounterDemo[test]}
Counter test: 3
> /invoke ${CounterDemo[default].Increment[8]}
> /echo ${CounterDemo}
Counter default: 8
> /invoke ${CounterDemo.Reset}
> /echo ${CounterDemo}
Counter default: 0
> /echo ${AllCountersDemo}
table: 0x381405b0
> /echo ${AllCountersDemo.Keys}
table: 0x38149388
> /echo ${AllCountersDemo.Keys.Length}
2
> /echo ${AllCountersDemo.Keys.Index[1]}
test
> /echo ${AllCountersDemo.Keys.Index[2]}
default
> /echo ${AllCountersDemo.Key[test]}
table: 0x38143108
> /echo ${AllCountersDemo.Key[test].Key[name]}
test
> /echo ${AllCountersDemo.Key[test].Key[value]}
3.00]]