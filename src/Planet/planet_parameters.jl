
# Properties of dry air
const Planet = CLIMAParameters.Planet
Planet.molmass_dryair(ps::AbstractEarthParameterSet) = 28.97e-3
Planet.R_d(ps::AbstractEarthParameterSet)            = gas_constant() / Planet.molmass_dryair(ps)
Planet.kappa_d(ps::AbstractEarthParameterSet)        = 2 / 7
Planet.cp_d(ps::AbstractEarthParameterSet)           = Planet.R_d(ps) / Planet.kappa_d(ps)
Planet.cv_d(ps::AbstractEarthParameterSet)           = Planet.cp_d(ps) - Planet.R_d(ps)

# Properties of water
Planet.ρ_cloud_liq(ps::AbstractEarthParameterSet)           = 1e3
Planet.ρ_cloud_ice(ps::AbstractEarthParameterSet)           = 916.7
Planet.molmass_water(ps::AbstractEarthParameterSet)         = 18.01528e-3
Planet.molmass_ratio(ps::AbstractEarthParameterSet)         = Planet.molmass_dryair(ps) / Planet.molmass_water(ps)
Planet.R_v(ps::AbstractEarthParameterSet)                   = gas_constant() / Planet.molmass_water(ps)
Planet.cp_v(ps::AbstractEarthParameterSet)                  = 1859
Planet.cp_l(ps::AbstractEarthParameterSet)                  = 4181
Planet.cp_i(ps::AbstractEarthParameterSet)                  = 2100
Planet.cv_v(ps::AbstractEarthParameterSet)                  = Planet.cp_v(ps) - Planet.R_v(ps)
Planet.cv_l(ps::AbstractEarthParameterSet)                  = Planet.cp_l(ps)
Planet.cv_i(ps::AbstractEarthParameterSet)                  = Planet.cp_i(ps)
Planet.T_freeze(ps::AbstractEarthParameterSet)              = 273.15
Planet.T_min(ps::AbstractEarthParameterSet)                 = 150.0
Planet.T_max(ps::AbstractEarthParameterSet)                 = 1000.0
Planet.T_icenuc(ps::AbstractEarthParameterSet)              = 233.00
Planet.pow_icenuc(ps::AbstractEarthParameterSet)            = 1
Planet.T_triple(ps::AbstractEarthParameterSet)              = 273.16
Planet.T_0(ps::AbstractEarthParameterSet)                   = Planet.T_triple(ps)
Planet.LH_v0(ps::AbstractEarthParameterSet)                 = 2.5008e6
Planet.LH_s0(ps::AbstractEarthParameterSet)                 = 2.8344e6
Planet.LH_f0(ps::AbstractEarthParameterSet)                 = Planet.LH_s0(ps) - Planet.LH_v0(ps)
Planet.e_int_v0(ps::AbstractEarthParameterSet)              = Planet.LH_v0(ps) - Planet.R_v(ps) * Planet.T_0(ps)
Planet.e_int_i0(ps::AbstractEarthParameterSet)              = Planet.LH_f0(ps)
Planet.press_triple(ps::AbstractEarthParameterSet)          = 611.657
Planet.surface_tension_coeff(ps::AbstractEarthParameterSet) = 0.072

Planet.entropy_dry_air(ps::AbstractEarthParameterSet)       = 6864.8
Planet.entropy_water_vapor(ps::AbstractEarthParameterSet)   = 10513.6
Planet.entropy_reference_temperature(ps::AbstractEarthParameterSet)  = 298.15

# Properties of sea water
Planet.ρ_ocean(ps::AbstractEarthParameterSet)        = 1.035e3
Planet.cp_ocean(ps::AbstractEarthParameterSet)       = 3989.25

# Planetary parameters
Planet.gravitational_constant(ps::AbstractEarthParameterSet) = 6.6743e-11
Planet.planet_mass(ps::AbstractEarthParameterSet)            = 5.9722e24
Planet.planet_radius(ps::AbstractEarthParameterSet)          = 6.371e6
Planet.day(ps::AbstractEarthParameterSet)                    = 86400
Planet.Omega(ps::AbstractEarthParameterSet)                  = 7.2921159e-5
Planet.grav(ps::AbstractEarthParameterSet)                   = 9.81
Planet.year_anom(ps::AbstractEarthParameterSet)              = 365.26 * Planet.day(ps)
Planet.orbit_semimaj(ps::AbstractEarthParameterSet)          = 1 * astro_unit()
Planet.tot_solar_irrad(ps::AbstractEarthParameterSet)        = 1362.0
Planet.epoch(ps::AbstractEarthParameterSet)                  = 2451545.0 * Planet.day(ps)
Planet.mean_anom_epoch(ps::AbstractEarthParameterSet)        = deg2rad(357.52911)
Planet.obliq_epoch(ps::AbstractEarthParameterSet)            = deg2rad(23.432777778)
Planet.lon_perihelion_epoch(ps::AbstractEarthParameterSet)   = deg2rad(282.937348)
Planet.eccentricity_epoch(ps::AbstractEarthParameterSet)     = 0.016708634
Planet.lon_perihelion(ps::AbstractEarthParameterSet)         = deg2rad(282.937348)
Planet.MSLP(ps::AbstractEarthParameterSet)                   = 1.01325e5
Planet.T_surf_ref(ps::AbstractEarthParameterSet)             = 290.0
Planet.T_min_ref(ps::AbstractEarthParameterSet)              = 220.0
