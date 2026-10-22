--!strict
-- Types for the editor only: when the specs run, Luau Run's Jest answers @jest/globals before any alias is read

type Block = (name: string, fn: () -> ()) -> ()
type Hook = (fn: () -> ()) -> ()

return {
	describe = (nil :: any) :: Block,
	it = (nil :: any) :: Block,
	test = (nil :: any) :: Block,
	expect = (nil :: any) :: (value: any) -> any,
	beforeAll = (nil :: any) :: Hook,
	beforeEach = (nil :: any) :: Hook,
	afterAll = (nil :: any) :: Hook,
	afterEach = (nil :: any) :: Hook,
	jest = nil :: any,
}
