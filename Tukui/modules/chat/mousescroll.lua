local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales
if C["chat"].enable ~= true then return end

local numlines = 3

local AddScrollAlert = function(self)
	if not self.ScrollButton then
		self.ScrollAlert = CreateFrame("Frame", nil, self)
		self.ScrollAlert:CreatePanel(nil, 20, 20, "BOTTOMRIGHT", self, "BOTTOMRIGHT", -1, 1)
		self.ScrollAlert:SetFrameStrata("DIALOG")
		self.ScrollAlert:EnableMouse(true)
		self.ScrollAlert:SetScript("OnMouseDown", function() self:ScrollToBottom() self.ScrollAlert:Hide() end)
		
		self.ScrollAlertTex = self.ScrollAlert:CreateTexture(nil, "OVERLAY")
		self.ScrollAlertTex:Point("TOPLEFT", 2, -2)
		self.ScrollAlertTex:Point("BOTTOMRIGHT", -2, 2)
		self.ScrollAlertTex:SetTexture("Interface\\Icons\\misc_arrowdown")
		self.ScrollAlertTex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	
		self.ScrollButton = true
	end
end

function FloatingChatFrame_OnMouseScroll(self, delta)
	if delta < 0 then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		else
			for i = 1, numlines do
				self:ScrollDown()
			end
		end
		
		if self.ScrollAlert and self.ScrollAlert:IsVisible() and self:AtBottom() then
			self.ScrollAlert:Hide()
		end
	elseif delta > 0 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		else
			for i = 1, numlines do
				self:ScrollUp()
			end
		end
		
		AddScrollAlert(self)
		if self.ScrollAlert and not self.ScrollAlert:IsVisible() then
			self.ScrollAlert:Show()
		end
	end
end