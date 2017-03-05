--v1.2

function ZapLib_FrameMoveable(unlock, movframe)
    if(unlock) then
        -- frame movement
        movframe:EnableMouse(true)      
    else
        -- frame dismovement
        movframe:EnableMouse(false)
    end
    movframe:RegisterForDrag("LeftButton")
    movframe:SetScript("OnDragStart", function(self) self:StartMoving() end)
    movframe:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
end

function ZapLib_DoubleDigit(num)
    if(num < 10) then
        return "0"..num;
    else
        return num;
    end
end

function ZapLib_BoolToString(bool)
    if(bool) then
        return "yes"
    else
        return "no"
    end
end

function UnitHasBuff(Unit, ID)
    local HasBuff = false;
    for i = 1, 40 do
        local BuffID = select(11,UnitBuff(Unit, i));
        if (BuffID == ID) then
            HasBuff = true;
        end
    end
    return HasBuff;
end