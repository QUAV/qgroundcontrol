#ifndef SPRAYER_H
#define SPRAYER_H

#include <QObject>

#include "ParameterManager.h"
#include "QGCMAVLink.h"
#include "QGCToolbox.h"
#include "QTimer"

class FirmwarePlugin;
class Vehicle;

class Sprayer : public QObject
{
    Q_OBJECT
public:
    Sprayer(Vehicle* vehicle);

    typedef enum {
       OUT_OF_FUMIGANT,
       DISACTIVATED,
       ACTIVATED,
       RTL,
       MASTER
    } sprayer_status_t;

protected:
    Vehicle*            _vehicle;

signals:
    void sprayerStatusChanged();

public slots:
    void _rcSprayerChanged(const int pwmSprayer);
    void _handleFumigantLevelSensor(const mavlink_message_t &message);

private slots:
    void _outOfLiquid(void);

public:
    FirmwarePlugin* firmwarePlugin() { return _firmwarePlugin; }

    sprayer_status_t status() const { return _status; }

    void setStatus(sprayer_status_t);

private:
   sprayer_status_t         _status;

   QGCToolbox*              _toolbox;
   SettingsManager*         _settingsManager;
   FirmwarePlugin*          _firmwarePlugin;
   ParameterManager*        _parameterManager   = nullptr;

   QTimer*                  _timer;

   void _handleSprayerSwitch(const int);
   bool _canBeActivated(const int);
   bool _canBeDisactivated(const int);
   void _activateSprayer(void);
   void _disactivateSprayer(void);
   void _sprayerController(void);
   bool _isSprayerEnabled(void);
   bool _stopSprayingMissionStatus(void);
   bool _startSprayingMissionStatus(void);
   void _toggleSprayer(bool);
   bool _isRTLFlightMode(Vehicle* vehicle, const QString& flightMode);
   void _tankFilled(void);

   void _say(const QString& text);
};

#endif // SPRAYER_H
