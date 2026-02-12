-- part protection
-- @02zoit | 11.02.2026

local Workspace = game:GetService("Workspace")

local MAX_DISTANCE = 5
local CHECK_INTERVAL = 1

local benchesFolder = Workspace:WaitForChild("Plate")
	:WaitForChild("Benches")

local benchData = {}

local function registerBench(bench)

	local parts = {}

	if bench:IsA("Model") then
		for _, obj in ipairs(bench:GetDescendants()) do
			if git push origin mainobj:IsA("BasePart") then
				table.insert(parts, {
					part = obj,
					originalCFrame = obj.CFrame
				})

				-- save existing benches
				if not obj.Anchored then
					pcall(function()
						obj:SetNetworkOwner(nil)
					end)
				end
			end
		end

	elseif bench:IsA("BasePart") then
		table.insert(parts, {
			part = bench,
			originalCFrame = bench.CFrame
		})

		if not bench.Anchored then
			pcall(function()
				bench:SetNetworkOwner(nil)
			end)
		end
	end

	if #parts > 0 then
		benchData[bench] = parts
	end
end

for _, bench in ipairs(benchesFolder:GetChildren()) do
	registerBench(bench)
end

benchesFolder.ChildAdded:Connect(function(child)
	task.wait()
	registerBench(child)
end)

task.spawn(function()
	while true do

		for bench, parts in pairs(benchData) do
			if bench and bench.Parent then
				
				for _, data in ipairs(parts) do
					local part = data.part

					if part and part.Parent then
						local dist = (part.Position - data.originalCFrame.Position).Magnitude

						if dist > MAX_DISTANCE then
							part.CFrame = data.originalCFrame
						end
					end
				end
			end
		end

		task.wait(CHECK_INTERVAL)
	end
end)