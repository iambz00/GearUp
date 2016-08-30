# GearUp 

An Equipment set manager

##### Features

* Equipment set swap on spec change.(To set named as spec name)

* Before spec change finishes, hold mod key(Alt, Ctrl, Shift) to swap another set named 'spec name' + 'mod suffix'
  * mod suffix : @ for Alt, ^ for Ctrl, # for Shift
  * _ex> Hold Alt key for 'Feral@', not 'Feral'_

* Bind key to all equipment sets

* Floating UI indicates current equipped set

##### Known problem

* Event "ACTIVE_TALENT_GROUP_CHANGED" fires twice on spec change.
  * So inner function is called twice, and causes "You can't do that right now." message.
  * Hoping Blizzard to fix or add corresponding event.


[Curse Link](https://mods.curse.com/addons/wow/gearup-upne/ )
[WowAce Project](https://www.wowace.com/addons/gearup-upne/ )