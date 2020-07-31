#ifndef SPRAYERMANAGER_H
#define SPRAYERMANAGER_H

#include <QObject>

#include "MultiVehicleManager.h"
#include "ParameterManager.h"
#include "QGCMAVLink.h"
#include "QGCToolbox.h"
#include "Sprayer.h"
#include "Vehicle.h"

class FirmwarePlugin;
class Vehicle;

class SprayerManager : public QGCTool
{
    Q_OBJECT
public:
    SprayerManager(QGCApplication* app, QGCToolbox* toolbox);

    // QGCTool overrides
    void setToolbox(QGCToolbox* toolbox) final;

private slots:
    void _settingsChanged       (void);

private:
    MultiVehicleManager*        _multiVehicleManager;
    Vehicle*                    _activeVehicle;
    Sprayer*                    _activeSprayer;

    bool                        _isSetRTLWhenEmpty;
    bool                        _isSetDisableSprayWhenEmpty;

    void                        _setActiveSprayer(bool);
    void                        _disconnectSprayer(void);
};

#endif // SPRAYERMANAGER_H
