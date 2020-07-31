#include "Sprayer.h"

#include "QGCApplication.h"
#include "SettingsManager.h"
#include "Vehicle.h"

Sprayer::Sprayer(Vehicle* vehicle)
    : _vehicle (vehicle)
    , _toolbox(qgcApp()->toolbox())
    , _firmwarePlugin(nullptr)

{
    _status = ACTIVATED;    // Start as activated
    _firmwarePlugin = _vehicle->firmwarePlugin();
    _parameterManager = _vehicle->parameterManager();

    _timer = new QTimer(this);
    _timer->setSingleShot(true);
    _timer->setInterval(3000);

    connect(_timer, &QTimer::timeout, this, &Sprayer::_outOfLiquid);
    connect(this, &Sprayer::sprayerStatusChanged, this, &Sprayer::_sprayerController);
}

void Sprayer::_rcSprayerChanged(const int pwmSprayer)
{
    if (pwmSprayer != -1) {
        _handleSprayerSwitch(pwmSprayer);
    }
}

void Sprayer::_handleSprayerSwitch(const int pwmSprayer)
{
    if (_canBeActivated(pwmSprayer)) {
        _activateSprayer();
    } else if (_canBeDisactivated(pwmSprayer)) {
        _disactivateSprayer();
    }
}

bool Sprayer::_canBeActivated(const int pwmSprayer)
{
    // Sprayer cannot be activated when lack of liquid was detected
    // Sprayer can be activated only if switch is in manual (<1200) or auto position (>1800)
    // While in auto position, it can be activated only if it has reached first WP and if is not in RTL mode

     return ( (_status == DISACTIVATED || _status == RTL) &&
              ((pwmSprayer < 1200) ||
               (pwmSprayer > 1800 && _vehicle->alreadyReachedFirstWP() == true && _isRTLFlightMode(_vehicle, _vehicle->flightMode()) == false)));
}

bool Sprayer::_canBeDisactivated(const int pwmSprayer)
{
    // Sprayer cannot be turned into disactivated state when lack of liquid was detected - it is in OUT_OF_FUMIGATION
    // Sprayer can be desactivated only if switch is netural (always off, <1200, 1800>) or auto position (>1800)
    // While in auto position, it can be disactivated if it has not reached first WP or if it is in RTL mode

    return ( (_status == ACTIVATED || _status == RTL) &&
             ((pwmSprayer > 1200 && pwmSprayer < 1800) ||
              (pwmSprayer > 1800 && (_vehicle->alreadyReachedFirstWP() == false || _isRTLFlightMode(_vehicle, _vehicle->flightMode()) == true))) );
}


void Sprayer::_activateSprayer(void)
{
    _status = ACTIVATED;
    emit sprayerStatusChanged();
}

void Sprayer::_disactivateSprayer(void)
{
    _status = DISACTIVATED;
    emit sprayerStatusChanged();
}

void Sprayer::_sprayerController(void)
{
    bool sprayerEnabled = _isSprayerEnabled();
    if (sprayerEnabled == true && _stopSprayingMissionStatus()) {
        _toggleSprayer(false);
    } else if (sprayerEnabled == false && _startSprayingMissionStatus()) {
        _toggleSprayer(true);
    }
}

bool Sprayer::_isSprayerEnabled(void)
{
    QString param = _firmwarePlugin->sprayEnabledParameter(_vehicle);

    if (!param.isEmpty() && _parameterManager->parameterExists(FactSystem::defaultComponentId, param)){
        Fact* fact = _parameterManager->getParameter(FactSystem::defaultComponentId, param);
        return fact->rawValue().toBool();
    }

    return false;
}

bool Sprayer::_stopSprayingMissionStatus(void)
{
    if (_status == DISACTIVATED || _status == OUT_OF_FUMIGANT){
        return true;
    } else {
        return false;
    }
}

bool Sprayer::_startSprayingMissionStatus(void)
{
    if (_status == ACTIVATED){
        return true;
    } else {
        return false;
    }
}

void Sprayer::_toggleSprayer(bool active)
{
    QString param = _firmwarePlugin->sprayEnabledParameter(_vehicle);

    if (!param.isEmpty() && _parameterManager->parameterExists(FactSystem::defaultComponentId, param) ){
        Fact* fact = _parameterManager->getParameter(FactSystem::defaultComponentId, param);
        fact->setRawValue(active);
    }
}

bool Sprayer::_isRTLFlightMode(Vehicle *_vehicle, const QString& flightMode)
{
    return (flightMode.compare(_vehicle->rtlFlightMode()) == 0 || flightMode.compare(_vehicle->smartRTLFlightMode()) == 0);
}

void Sprayer::_handleFumigantLevelSensor(const mavlink_message_t& message)
{
    mavlink_button_change_t fumigant_level;
    mavlink_msg_button_change_decode(&message, &fumigant_level);

    //qDebug() << "State: " << fumigant_level.state << " | Sprayer: " << _status
    //         << " | Armed: " << _vehicle->armed() << " | SPRAY_ENABLED: " << _isSprayerEnabled() ;

    // If there is no liquid and and the warning has not been shown yet

    if (fumigant_level.state == 1 && _status != OUT_OF_FUMIGANT){
        _timer->start();
    } else if (fumigant_level.state == 0 && _status != OUT_OF_FUMIGANT && _timer->isActive()){
        _timer->stop();
    } else if (fumigant_level.state == 0){
        _tankFilled();
    }
}

void Sprayer::_outOfLiquid(void)
{
    qgcApp()->showMessage(tr("Out of fumigation liquid."));
    _say(tr("Out of fumigation liquid. Switching to RTL mode."));
    _status = OUT_OF_FUMIGANT;

    if (_toolbox->settingsManager()->appSettings()->enableRTLWhenEmpty()->rawValue().toBool()){
        _vehicle->setFlightMode(_firmwarePlugin->rtlFlightMode());
    }

    if (_toolbox->settingsManager()->appSettings()->disableSprayWhenEmpty()->rawValue().toBool()){
        // qDebug () << "Entering OUT_OF_FUMIGANT status";
        emit sprayerStatusChanged();
    }
}

void Sprayer::_tankFilled(void)
{
    _status = ACTIVATED;
    if (_isSprayerEnabled() == false){
        _toggleSprayer(true);
    }
}

void Sprayer::_say(const QString& text)
{
    _toolbox->audioOutput()->say(text.toLower());
}

void Sprayer::setStatus(sprayer_status_t newStatus)
{
    _status = newStatus;
    emit sprayerStatusChanged();
}
