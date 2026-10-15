--!strict
--[[
	Coverage-free guidance: a seen-fingerprint set + a working corpus of retained program
	prefixes. A seed whose checkpoint reaches a NOVEL fingerprint has its prefix retained for
	the mutator to draw from; repeats are dropped. Engine-agnostic (a fingerprint is a number,
	a prefix is opaque). Use it only where it is shown to kill mutants faster than
	random+swarm (BeDivFuzz: a diversity proxy can win while bug-finding loses to random).
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

-- Returns true + retains the prefix iff this fingerprint is novel
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
