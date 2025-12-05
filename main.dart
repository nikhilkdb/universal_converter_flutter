// lib/main.dart
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(UniversalConverterApp());

class UniversalConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universal Converter (HVAC)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ConverterHome(),
    );
  }
}

/// Home with top-level tabs: Basic, HVAC, Quick
class ConverterHome extends StatefulWidget {
  @override
  _ConverterHomeState createState() => _ConverterHomeState();
}

class _ConverterHomeState extends State<ConverterHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> topTabs = const [
    Tab(text: 'Basic'),
    Tab(text: 'HVAC'),
    Tab(text: 'Quick'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: topTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universal Converter (HVAC)'),
        bottom: TabBar(
          controller: _tabController,
          tabs: topTabs,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Basic set: one tab with many category sub-tabs
          CategoryTabs(
            titlePrefix: 'Basic',
            categories: basicCategories,
          ),
          // HVAC-focused set
          CategoryTabs(
            titlePrefix: 'HVAC',
            categories: hvacCategories,
          ),
          // Quick minimal
          CategoryTabs(
            titlePrefix: 'Quick',
            categories: quickCategories,
          ),
        ],
      ),
    );
  }
}

/// A component that exposes categories as internal tabs (scrollable)
class CategoryTabs extends StatefulWidget {
  final String titlePrefix;
  final List<ConverterCategory> categories;
  const CategoryTabs({
    Key? key,
    required this.titlePrefix,
    required this.categories,
  }) : super(key: key);

  @override
  _CategoryTabsState createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs>
    with SingleTickerProviderStateMixin {
  late TabController _innerController;

  @override
  void initState() {
    super.initState();
    _innerController =
        TabController(length: widget.categories.length, vsync: this);
  }

  @override
  void dispose() {
    _innerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Theme.of(context).primaryColorLight,
          child: TabBar(
            controller: _innerController,
            isScrollable: true,
            tabs: widget.categories.map((c) => Tab(text: c.name)).toList(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _innerController,
            children:
                widget.categories.map((c) => ConverterPage(category: c)).toList(),
          ),
        ),
      ],
    );
  }
}

//
// Data models
//
class ConverterCategory {
  final String id;
  final String name;
  final List<Unit> units;
  final String hint;
  const ConverterCategory({
    required this.id,
    required this.name,
    required this.units,
    required this.hint,
  });
}

class Unit {
  final String id;
  final String name;
  const Unit({required this.id, required this.name});
}

//
// CATEGORY DEFINITIONS
//

final List<ConverterCategory> basicCategories = [
  ConverterCategory(
    id: 'temperature',
    name: 'Temperature',
    hint: '°C, °F, K',
    units: const [
      Unit(id: 'c', name: '°C'),
      Unit(id: 'f', name: '°F'),
      Unit(id: 'k', name: 'K'),
    ],
  ),
  ConverterCategory(
    id: 'pressure',
    name: 'Pressure',
    hint: 'Pa, kPa, psi, inH₂O, mmHg',
    units: const [
      Unit(id: 'pa', name: 'Pa'),
      Unit(id: 'kpa', name: 'kPa'),
      Unit(id: 'psi', name: 'psi'),
      Unit(id: 'inh2o', name: 'inH₂O'),
      Unit(id: 'mmhg', name: 'mmHg'),
    ],
  ),
  ConverterCategory(
    id: 'length',
    name: 'Length',
    hint: 'm, mm, ft, in',
    units: const [
      Unit(id: 'm', name: 'm'),
      Unit(id: 'mm', name: 'mm'),
      Unit(id: 'ft', name: 'ft'),
      Unit(id: 'in', name: 'in'),
    ],
  ),
  ConverterCategory(
    id: 'airflow',
    name: 'Airflow',
    hint: 'm³/s, L/s, CFM',
    units: const [
      Unit(id: 'cms', name: 'm³/s'),
      Unit(id: 'ls', name: 'L/s'),
      Unit(id: 'm3h', name: 'm³/h'),
      Unit(id: 'cfm', name: 'CFM'),
    ],
  ),
  ConverterCategory(
    id: 'power',
    name: 'Power',
    hint: 'W, kW, BTU/h, Tons',
    units: const [
      Unit(id: 'w', name: 'W'),
      Unit(id: 'kw', name: 'kW'),
      Unit(id: 'btu_h', name: 'BTU/h'),
      Unit(id: 'ton', name: 'Tons (ref)'),
    ],
  ),
  ConverterCategory(
    id: 'energy',
    name: 'Energy',
    hint: 'J, kWh, BTU',
    units: const [
      Unit(id: 'j', name: 'J'),
      Unit(id: 'kwh', name: 'kWh'),
      Unit(id: 'btu', name: 'BTU'),
    ],
  ),
];

final List<ConverterCategory> hvacCategories = [
  // Pressure with inch WC & Pa
  ConverterCategory(
    id: 'pressure_hvac',
    name: 'Pressure (HVAC)',
    hint: 'Pa, inH₂O, psi, mmHg',
    units: const [
      Unit(id: 'pa', name: 'Pa'),
      Unit(id: 'inh2o', name: 'inH₂O'),
      Unit(id: 'psi', name: 'psi'),
      Unit(id: 'mmhg', name: 'mmHg'),
    ],
  ),
  // Airflow with m3/h, velocity, duct helper
  ConverterCategory(
    id: 'airflow_hvac',
    name: 'Airflow & Ducts',
    hint: 'CFM, m³/h, L/s, velocity ↔ area helper',
    units: const [
      Unit(id: 'cfm', name: 'CFM'),
      Unit(id: 'm3h', name: 'm³/h'),
      Unit(id: 'ls', name: 'L/s'),
      Unit(id: 'cms', name: 'm³/s'),
    ],
  ),
  // Power and refrigeration tons
  ConverterCategory(
    id: 'power_hvac',
    name: 'Power & Cooling',
    hint: 'W, kW, BTU/h, Tons',
    units: const [
      Unit(id: 'w', name: 'W'),
      Unit(id: 'kw', name: 'kW'),
      Unit(id: 'btu_h', name: 'BTU/h'),
      Unit(id: 'ton', name: 'Tons (ref)'),
    ],
  ),
  // Psychrometric helpers (simple)
  ConverterCategory(
    id: 'psychro',
    name: 'Psychrometrics (basic)',
    hint: 'Dry bulb, dew point, RH, humidity ratio (approx)',
    units: const [
      Unit(id: 'db', name: 'Dry bulb °C'),
      Unit(id: 'rh', name: 'Relative Humidity %'),
      Unit(id: 'dp', name: 'Dew point °C'),
    ],
  ),
];

final List<ConverterCategory> quickCategories = [
  ConverterCategory(
    id: 'quick_temp',
    name: 'Temp Quick',
    hint: '°C ↔ °F',
    units: const [
      Unit(id: 'c', name: '°C'),
      Unit(id: 'f', name: '°F'),
    ],
  ),
  ConverterCategory(
    id: 'quick_cfm',
    name: 'Flow Quick',
    hint: 'CFM ↔ m³/h',
    units: const [
      Unit(id: 'cfm', name: 'CFM'),
      Unit(id: 'm3h', name: 'm³/h'),
    ],
  ),
];

//
// Converter Page
//
class ConverterPage extends StatefulWidget {
  final ConverterCategory category;
  const ConverterPage({Key? key, required this.category}) : super(key: key);

  @override
  _ConverterPageState createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final TextEditingController _inputController = TextEditingController();
  late String _fromUnitId;
  late String _toUnitId;
  String _result = '';
  final List<String> _history = [];

  // Additional HVAC inputs for special calculators
  final TextEditingController _ductDiameterController = TextEditingController();
  final TextEditingController _velocityController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fromUnitId = widget.category.units.first.id;
    _toUnitId =
        (widget.category.units.length > 1) ? widget.category.units[1].id : widget.category.units.first.id;
    _inputController.addListener(_convert);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _ductDiameterController.dispose();
    _velocityController.dispose();
    _areaController.dispose();
    _humidityController.dispose();
    super.dispose();
  }

  void _convert() {
    final inputText = _inputController.text.trim();
    if (inputText.isEmpty) {
      setState(() {
        _result = '';
      });
      return;
    }
    final value = double.tryParse(inputText);
    if (value == null) {
      setState(() {
        _result = 'Invalid number';
      });
      return;
    }

    double converted;
    try {
      converted = convert(widget.category.id, _fromUnitId, _toUnitId, value);
    } catch (e) {
      converted = double.nan;
    }

    setState(() {
      if (converted.isNaN) {
        _result = 'Cannot convert';
      } else {
        final s = converted.toStringAsPrecision(6);
        _result = '$s ${_unitName(_toUnitId)}';
        _addHistory('${value.toString()} ${_unitName(_fromUnitId)} → $s ${_unitName(_toUnitId)}');
      }
    });
  }

  void _addHistory(String entry) {
    if (_history.isEmpty || _history.first != entry) {
      setState(() {
        _history.insert(0, entry);
        if (_history.length > 12) _history.removeLast();
      });
    }
  }

  String _unitName(String id) {
    final u = widget.category.units.firstWhere((x) => x.id == id, orElse: () => widget.category.units.first);
    return u.name;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Text(widget.category.hint, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Value',
                    hintText: 'Enter value to convert',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    onPressed: () {
                      setState(() {
                        final tmp = _fromUnitId;
                        _fromUnitId = _toUnitId;
                        _toUnitId = tmp;
                        _convert();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildUnitDropdown('From', _fromUnitId, (String? v) {
                if (v == null) return;
                setState(() {
                  _fromUnitId = v;
                  _convert();
                });
              })),
              const SizedBox(width: 12),
              Expanded(child: _buildUnitDropdown('To', _toUnitId, (String? v) {
                if (v == null) return;
                setState(() {
                  _toUnitId = v;
                  _convert();
                });
              })),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Result', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(_result.isEmpty ? '--' : _result, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // HVAC special helpers for appropriate categories
          if (widget.category.id == 'airflow_hvac') _buildAirflowDuctHelper(),
          if (widget.category.id == 'power_hvac') _buildTonnageHelper(),
          if (widget.category.id == 'psychro') _buildPsychroHelper(),

          const SizedBox(height: 12),
          Expanded(child: _buildHistory()),
        ],
      ),
    );
  }

  Widget _buildUnitDropdown(String label, String value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            underline: const SizedBox.shrink(),
            items: widget.category.units.map((u) => DropdownMenuItem(value: u.id, child: Text(u.name))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('History', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Expanded(
          child: _history.isEmpty
              ? const Center(child: Text('No recent conversions'))
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (_, i) => ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(_history[i]),
                    onTap: () {
                      // try to parse first numeric token and set as input
                      final first = _history[i].split(' ').first;
                      final v = double.tryParse(first);
                      if (v != null) {
                        setState(() {
                          _inputController.text = v.toString();
                          _convert();
                        });
                      }
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // --- HVAC Helpers ---

  Widget _buildAirflowDuctHelper() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Duct velocity / area helper', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ductDiameterController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Duct diameter (mm)',
                      hintText: 'e.g. 200',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _velocityController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Velocity (m/s)',
                      hintText: 'e.g. 5',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final d = double.tryParse(_ductDiameterController.text);
                    final v = double.tryParse(_velocityController.text);
                    if (d == null || v == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter diameter & velocity')));
                      return;
                    }
                    // area m^2 = pi*(D/1000)^2/4
                    final area = pi * pow(d / 1000.0, 2) / 4.0;
                    // flow m^3/s = area * velocity
                    final q = area * v;
                    final q_cfm = q / 0.00047194745;
                    setState(() {
                      _result = '${q.toStringAsPrecision(6)} m³/s  (≈ ${q_cfm.toStringAsPrecision(6)} CFM)';
                      _addHistory('Duct ${d} mm, ${v} m/s → ${q.toStringAsPrecision(6)} m³/s');
                    });
                  },
                  child: const Text('Calc'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Tip: Enter diameter and velocity, press Calc.'),
          ],
        ),
      ),
    );
  }

  Widget _buildTonnageHelper() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tonnage helper', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('1 ton (ref) ≈ 3516.852842 W'),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Value',
                  hintText: 'Enter number to convert using dropdown',
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _convert,
              child: const Text('Convert'),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildPsychroHelper() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Psychrometric quick helper (approx)', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _inputController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Dry bulb temp °C',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _humidityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Relative Humidity %',
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final db = double.tryParse(_inputController.text);
              final rh = double.tryParse(_humidityController.text);
              if (db == null || rh == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter DB and RH')));
                return;
              }
              final dp = _approxDewPoint(db, rh);
              final humRatio = _approxHumidityRatio(db, rh);
              setState(() {
                _result = 'Dew point ≈ ${dp.toStringAsPrecision(5)} °C, w ≈ ${humRatio.toStringAsPrecision(5)} kg/kg';
                _addHistory('DB ${db}°C, RH ${rh}% → DP ${dp.toStringAsPrecision(5)}°C');
              });
            },
            child: const Text('Compute'),
          ),
          const SizedBox(height: 6),
          const Text('Note: These are approximations for quick estimates.'),
        ]),
      ),
    );
  }
}

//
// Conversion engine
//
double convert(String categoryId, String from, String to, double value) {
  switch (categoryId) {
    // basic categories
    case 'temperature':
    case 'quick_temp':
      return _convertTemperature(from, to, value);
    case 'pressure':
    case 'pressure_hvac':
      return _convertPressure(from, to, value);
    case 'length':
      return _convertLength(from, to, value);
    case 'airflow':
    case 'airflow_hvac':
    case 'quick_cfm':
      return _convertAirflow(from, to, value);
    case 'power':
    case 'power_hvac':
      return _convertPower(from, to, value);
    case 'energy':
      return _convertEnergy(from, to, value);
    case 'psychro':
      // psychro page uses dedicated helper - no direct unit conversions here
      return double.nan;
    default:
      return double.nan;
  }
}

// Temperature conversions
double _convertTemperature(String from, String to, double v) {
  double c;
  if (from == 'c') c = v;
  else if (from == 'f') c = (v - 32) * 5 / 9;
  else if (from == 'k') c = v - 273.15;
  else return double.nan;

  if (to == 'c') return c;
  if (to == 'f') return (c * 9 / 5) + 32;
  if (to == 'k') return c + 273.15;
  return double.nan;
}

// Pressure conversions (base Pa)
double _convertPressure(String from, String to, double v) {
  double pa;
  switch (from) {
    case 'pa':
      pa = v;
      break;
    case 'kpa':
      pa = v * 1000;
      break;
    case 'psi':
      pa = v * 6894.757;
      break;
    case 'inh2o':
      // 1 inH2O ≈ 248.84 Pa (approx common HVAC reference)
      pa = v * 248.84;
      break;
    case 'mmhg':
      pa = v * 133.322;
      break;
    default:
      return double.nan;
  }

  switch (to) {
    case 'pa':
      return pa;
    case 'kpa':
      return pa / 1000;
    case 'psi':
      return pa / 6894.757;
    case 'inh2o':
      return pa / 248.84;
    case 'mmhg':
      return pa / 133.322;
    default:
      return double.nan;
  }
}

// Length (base meter)
double _convertLength(String from, String to, double v) {
  double m;
  switch (from) {
    case 'm':
      m = v;
      break;
    case 'mm':
      m = v / 1000;
      break;
    case 'ft':
      m = v * 0.3048;
      break;
    case 'in':
      m = v * 0.0254;
      break;
    default:
      return double.nan;
  }

  switch (to) {
    case 'm':
      return m;
    case 'mm':
      return m * 1000;
    case 'ft':
      return m / 0.3048;
    case 'in':
      return m / 0.0254;
    default:
      return double.nan;
  }
}

// Airflow conversions. base m^3/s
// 1 L/s = 0.001 m^3/s
// 1 CFM = 0.00047194745 m^3/s
// 1 m³/h = 1/3600 m³/s
double _convertAirflow(String from, String to, double v) {
  double m3s;
  switch (from) {
    case 'cms':
      m3s = v;
      break;
    case 'ls':
      m3s = v * 0.001;
      break;
    case 'cfm':
      m3s = v * 0.00047194745;
      break;
    case 'm3h':
      m3s = v / 3600.0;
      break;
    default:
      return double.nan;
  }

  switch (to) {
    case 'cms':
      return m3s;
    case 'ls':
      return m3s / 0.001;
    case 'cfm':
      return m3s / 0.00047194745;
    case 'm3h':
      return m3s * 3600.0;
    default:
      return double.nan;
  }
}

// Power conversions. base Watt
// 1 kW = 1000 W
// 1 BTU/h = 0.29307107 W
// 1 ton refrigeration = 3516.852842 W
double _convertPower(String from, String to, double v) {
  double w;
  switch (from) {
    case 'w':
      w = v;
      break;
    case 'kw':
      w = v * 1000;
      break;
    case 'btu_h':
      w = v * 0.29307107;
      break;
    case 'ton':
    case 'Tons (ref)':
      w = v * 3516.852842;
      break;
    default:
      return double.nan;
  }

  switch (to) {
    case 'w':
      return w;
    case 'kw':
      return w / 1000;
    case 'btu_h':
      return w / 0.29307107;
    case 'ton':
    case 'Tons (ref)':
      return w / 3516.852842;
    default:
      return double.nan;
  }
}

// Energy conversions. base Joule
// 1 kWh = 3.6e6 J
// 1 BTU ≈ 1055.05585 J
double _convertEnergy(String from, String to, double v) {
  double j;
  switch (from) {
    case 'j':
      j = v;
      break;
    case 'kwh':
      j = v * 3.6e6;
      break;
    case 'btu':
      j = v * 1055.05585;
      break;
    default:
      return double.nan;
  }

  switch (to) {
    case 'j':
      return j;
    case 'kwh':
      return j / 3.6e6;
    case 'btu':
      return j / 1055.05585;
    default:
      return double.nan;
  }
}

//
// Simple psychrometric approximations (for quick estimates only)
//

// Magnus formula approximate dew point (°C) from T (°C) and RH (%)
double _approxDewPoint(double tC, double rhPercent) {
  final a = 17.27;
  final b = 237.7;
  final rh = rhPercent.clamp(0.0001, 100.0) / 100.0;
  final alpha = (a * tC) / (b + tC) + log(rh);
  final dp = (b * alpha) / (a - alpha);
  return dp;
}

// Approximate humidity ratio (kg water / kg dry air) - rough
// w ≈ 0.622 * Pv / (P - Pv) where Pv is vapor pressure (Pa) and P ~ 101325 Pa
double _approxHumidityRatio(double tC, double rhPercent) {
  final es = 6.112 * exp((17.67 * tC) / (tC + 243.5)); // hPa
  final ea = es * (rhPercent / 100.0); // hPa
  final Pv = ea * 100.0; // Pa
  final P = 101325.0; // Pa
  final w = 0.622 * Pv / (P - Pv);
  return w;
}
