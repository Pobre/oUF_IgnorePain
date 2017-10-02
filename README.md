# oUF IgnorePain
----

## Description

oUF IgnorePain is an element plug-in for unitframe framework oUF.  
It does nothing by itself, it is to be used in a layout that supports it.

Features:

* Ignore Pain bar with current and maximum absorb pool.
* Tags: current and maximum.

## How to implement

```lua
local IgnorePain = CreateFrame("StatusBar", nil, self)  
IgnorePain:SetSize(120, 20)  
IgnorePain:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 0)

self:Tag(YourTagFrame, "[ignorepain:cur]") -- Current IgnorePain absorb  
self:Tag(YourTagFrame2, "[ignorepain:max]") -- Maximum IgnorePain absorb

-- Register with oUF  
self.IgnorePain = IgnorePain
```

**It's a good idea to create this element only when the Warrior is in Protection Specialization.**

## Feedback

Any suggestions or questions, please use the comments section.
Want to report a bug or contribute to the project? Please follow [this link](https://github.com/Pobre/oUF_IgnorePain/issues?q=) to get started.

## Legal

You can read the license [here](https://github.com/Pobre/oUF_IgnorePain/blob/master/LICENSE.txt).

