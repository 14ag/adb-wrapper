::[Bat To Exe Converter]
::
::fBE1pAF6MU+EWHreyHcjLQlHcBSKNWezFokP6f346taGpk9QQ/A+aJ/eyIiHLvMH60noOJcj0mhVkc9BDQtIbVypbxtU
::YAwzoRdxOk+EWAjk
::fBw5plQjdCuDJFqR51Y/JQhoRQeNMniGB7sY+ufy66ePp0wZa+QzeZuV07eBQA==
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSDk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpSI=
::egkzugNsPRvcWATEpSI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFAtcRQiLLFepB6Af7dT66+jKtV8cRPI6arPa3rbDN/IS+lXhZ9gozn86
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
:args
set "a=%*"
set "a0=%~0"
setlocal enabledelayedexpansion
set "a1=%a%"
if defined a1 (
    for /f "tokens=*" %%i in ("!a1:%a0%=!") do (
        endlocal & set "args=%%i"
    )
)

if defined args (
    set "args=%args:"=%"
    cmd /k "install-android-apps.bat %args%"
) 

exit /b
