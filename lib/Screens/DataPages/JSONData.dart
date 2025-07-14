// ignore_for_file: non_constant_identifier_names

class Data {
    int? datetime;
    double? airTemperature;
    double? Precipitation;
    double? maxPrecipRate;
    double? atmosphericPressure;
    double? relativeHumidity;
    double? soilTemperature5;
    double? soilTemperature10;
    double? soilTemperature20;
    double? soilTemperature50;
    double? soilTemperature100;
    double? soilVWC5;
    double? soilVWC10;
    double? soilVWC20;
    double? soilVWC50;
    double? soilVWC100;
    double? bulkEC5;
    double? bulkEC10;
    double? bulkEC20;
    double? bulkEC50;
    double? bulkEC100;
    double? solarRadiation;
    double? windDirection;
    double? windSpeed;
    double? gustSpeed;
    double? snowDepth;

    Data({
      this.datetime,
      this.airTemperature,
      this.Precipitation,
      this.maxPrecipRate,
      this.atmosphericPressure,
      this.relativeHumidity,
      this.soilTemperature5,
      this.soilTemperature10,
      this.soilTemperature20,
      this.soilTemperature50,
      this.soilTemperature100,
      this.soilVWC5,
      this.soilVWC10,
      this.soilVWC20,
      this.soilVWC50,
      this.soilVWC100,
      this.bulkEC5,
      this.bulkEC10,
      this.bulkEC20,
      this.bulkEC50,
      this.bulkEC100,
      this.solarRadiation,
      this.windDirection,
      this.windSpeed,
      this.gustSpeed,
      this.snowDepth,
    });

  factory Data.fromJson(Map<String,dynamic> json) {
    return Data(
    datetime: json['datetime'],
    airTemperature: json['Air Temperature @ 2 m [°F]'] ?? json['Air Temperature @ 8 ft [°F]'],
    Precipitation: json['Precipitation [in]'],
    maxPrecipRate: json['Max Precip Rate [in/hr]'],
    atmosphericPressure: json['Atmospheric Pressure [mbar]'],
    relativeHumidity: json['Relative Humidity [%]'],
    soilTemperature5: json['Soil Temperature @ -5 cm [°F]'],
    soilTemperature10: json['Soil Temperature @ -10 cm [°F]'],
    soilTemperature20: json['Soil Temperature @ -20 cm [°F]'],
    soilTemperature50: json['Soil Temperature @ -50 cm [°F]'],
    soilTemperature100: json['Soil Temperature @ -100 cm [°F]'] ?? json['Soil Temperature @ -91 cm [°F]'],
    soilVWC5: json['Soil VWC @ -5 cm [%]'],
    soilVWC10: json['Soil VWC @ -10 cm [%]'],
    soilVWC20: json['Soil VWC @ -20 cm [%]'],
    soilVWC50: json['Soil VWC @ -50 cm [%]'],
    soilVWC100: json['Soil VWC @ -100 cm [%]'] ?? json['Soil VWC @ -91 cm [%]'],
    bulkEC5: json['Bulk EC @ -5 cm [mS/cm]'],
    bulkEC10: json['Bulk EC @ -10 cm [mS/cm]'],
    bulkEC20: json['Bulk EC @ -20 cm [mS/cm]'],
    bulkEC50: json['Bulk EC @ -50 cm [mS/cm]'],
    bulkEC100: json['Bulk EC @ -100 cm [mS/cm]'] ?? json['Bulk EC @ -91 cm [mS/cm]'],
    solarRadiation: json['Solar Radiation [W/m²]'],
    windDirection: json['Wind Direction @ 10 m [deg]'] ?? json['Wind Direction @ 8 ft [deg]'],
    windSpeed: json['Wind Speed @ 10 m [mi/h]'] ?? json['Wind Speed @ 8 ft [mi/h]'],
    gustSpeed: json['Gust Speed @ 10 m [mi/h]'] ?? json['Gust Speed @ 8 ft [mi/h]'],
    snowDepth: json['Snow Depth [in]'],
      );
  }
}
