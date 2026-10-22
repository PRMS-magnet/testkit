--!strict
--[[
	Keeps a program prefix the first time its state fingerprint is seen, as a corpus for the
	mutator. New states are not new bugs, and guidance like this can lose to plain random
	inputs (BeDivFuzz), so measure it against random before relying on it.
]]
local Guidance = {}
Guidance.__index = Guidance

export type Guidance = typeof(setmetatable(
	{} :: {
		_Seen: { [number]: boolean },
		_Corpus: { any },
	},
	Guidance
))

function Guidance.new(): Guidance
	return setmetatable({ _Seen = {}, _Corpus = {} }, Guidance) :: any
end

-- True when the fingerprint is new, which also keeps the prefix
function Guidance.Observe(self: Guidance, fingerprint: number, prefix: any): boolean
	if self._Seen[fingerprint] then
		return false
	end
	self._Seen[fingerprint] = true
	table.insert(self._Corpus, prefix)
	return true
end

function Guidance.Corpus(self: Guidance): { any }
	return self._Corpus
end

return Guidance
