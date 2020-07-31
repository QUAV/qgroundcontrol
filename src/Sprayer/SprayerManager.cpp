#include "SprayerManager.h"

#include "QGCApplication.h"
#include "SettingsManager.h"

SprayerManager::SprayerManager(QGCApplication* app, QGCToolbox* toolbox)
    : QGCTool(app, toolbox)
    , _multiVehicleManager(nullptr)
    , _activeSprayer(nullptr)
{
}

void SprayerManager::setToolbox(QGCToolbox* toolbox)
{
    QGCTool::setToolbox(toolbox);
    _multiVehicleManager = _toolbox->multiVehicleManager();

    connect(toolbox->settingsManager()->appSettings()->enableRTLWhenEmpty(),     &Fact::rawValueChanged, this, &SprayerManager::_settingsChanged);
    connect(toolbox->settingsManager()->appSettings()->disableSprayWhenEmpty(),  &Fact::rawValueChanged, this, &SprayerManager::_settingsChanged);
}

void SprayerManager::_settingsChanged(void)
{
     // There is no need to check if vehicle is active, because of the checkbox condition
    _activeVehicle = _multiVehicleManager->activeVehicle();
    _isSetRTLWhenEmpty = _toolbox->settingsManager()->appSettings()->enableRTLWhenEmpty()->rawValue().toBool();
    _isSetDisableSprayWhenEmpty = _toolbox->settingsManager()->appSettings()->disableSprayWhenEmpty()->rawValue().toBool();

    if (_activeSprayer == nullptr){
        _setActiveSprayer(true);
    } else if (_isSetRTLWhenEmpty == false && _isSetDisableSprayWhenEmpty == false){
        _setActiveSprayer(false);
    }
}

void SprayerManager::_setActiveSprayer(bool status)
{
    if (status){
        _activeSprayer = new Sprayer(_activeVehicle);
        connect(_activeVehicle, &Vehicle::handleFumigantLevelSensor, _activeSprayer, &Sprayer::_handleFumigantLevelSensor);
    } else {
        disconnect(_activeVehicle, &Vehicle::handleFumigantLevelSensor, _activeSprayer, &Sprayer::_handleFumigantLevelSensor);
        delete _activeSprayer;
        _activeSprayer = nullptr;
    }
}
