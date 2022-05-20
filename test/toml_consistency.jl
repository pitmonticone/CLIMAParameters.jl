using Test

# import CLIMAParameters
import CLIMAParameters
const CP = CLIMAParameters

# read parameters needed for tests
full_parameter_set = CP.create_parameter_struct(Float64; dict_type = "alias")

struct EarthParameterSet <: CP.AbstractEarthParameterSet end
const param_set_cpp = EarthParameterSet()

universal_constant_aliases = [
    "gas_constant",
    "light_speed",
    "h_Planck",
    "k_Boltzmann",
    "Stefan",
    "astro_unit",
    "avogad",
]

@testset "load with name or alias" begin
    @test_throws AssertionError CP.create_parameter_struct(
        Float64;
        dict_type = "not name or alias",
    )

end

@testset "Test write / log parameters" begin

    for (k, v) in full_parameter_set #iterates over data (by alias)
        # for the logfile test later:
        CP.get_parameter_values!(
            full_parameter_set,
            k,
            "test_component", # e.g., "Thermodynamics"
        )
    end
    full_parameter_set_from_log = mktempdir() do path
        logfilepath1 = joinpath(path, "log_file_test_1.toml")
        #create a dummy log file listing where CLIMAParameter lives
        CP.log_parameter_information(full_parameter_set, logfilepath1)
        # CP.write_log_file(full_parameter_set, logfilepath1)

        #read in log file as new parameter file and rerun test.
        CP.create_parameter_struct(
            Float64;
            override_file = logfilepath1,
            dict_type = "alias",
        )
    end
    # Make sure logging preserves parameter set values
    for (k, v) in full_parameter_set #iterates over data (by alias)
        @test v["value"] == full_parameter_set_from_log[k]["value"]
    end
end

@testset "parameter arrays" begin
    # Tests to check if file parsing, extracting and logging of parameter
    # values also works with array-valued parameters

    # Create parameter structs consisting of the parameters contained in the
    # default parameter file ("parameters.toml") and additional (array valued)
    # parameters ("array_parameters.toml").
    path_to_array_params = joinpath(@__DIR__, "toml", "array_parameters.toml")
    # parameter struct of type Float64 (default)
    param_set = CP.create_parameter_struct(
        Float64;
        override_file = path_to_array_params,
        dict_type = "name",
    )
    # parameter struct of type Float32
    param_set_f32 = CP.create_parameter_struct(
        Float32;
        override_file = path_to_array_params,
        dict_type = "name",
    )

    # true parameter values (used to check if values are correctly read from
    # the toml file)
    true_param_1 = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    true_param_2 = [0.0, 1.0, 1.0, 2.0, 3.0, 5.0, 8.0, 13.0, 21.0, 34.0]
    true_param_3 = [9.81, 10.0]
    true_param_4 = 299792458
    true_params = [true_param_1, true_param_2, true_param_3, true_param_4]
    param_names = [
        "array_parameter_1",
        "array_parameter_2",
        "gravitational_acceleration",
        "light_speed",
    ]

    # Let's assume that parameter_vector_1 and parameter_vector_2 are used
    # in a module called "Test"
    mod = "Test"

    # Get parameter values and add information on the module where the
    # parameters are used.
    for i in range(1, stop = length(true_params))

        param_pair = CP.get_parameter_values!(param_set, param_names[i], mod)
        param = last(param_pair)
        @test param == true_params[i]
        # Check if the parameter is of the correct type. It should have
        # the same type as the ParamDict, which is specified by the
        # `float_type` argument to `create_parameter_struct`.
        @test eltype(param) == Float64

        param_f32_pair =
            CP.get_parameter_values!(param_set_f32, param_names[i], mod)
        param_f32 = last(param_f32_pair)
        @test eltype(param_f32) == Float32

    end

    # Get several parameter values (scalar and arrays) at once
    params = CP.get_parameter_values(param_set, param_names)
    for j in 1:length(param_names)
        param_val = last(params[j])
        @test param_val == true_params[j]
    end

    # Write parameters to log file
    mktempdir(@__DIR__) do path
        logfilepath2 = joinpath(path, "log_file_test_2.toml")
        CP.write_log_file(param_set, logfilepath2)
    end

    # `param_set` and `full_param_set` contain different values for the
    # `gravitational_acceleration` parameter. The merged parameter set should
    # contain the value from `param_set`.
    full_param_set = CP.create_parameter_struct(Float64; dict_type = "name")
    merged_param_set =
        CP.merge_override_default_values(param_set, full_param_set)
    grav_pair =
        CP.get_parameter_values(merged_param_set, "gravitational_acceleration")
    grav = last(grav_pair)
    @test grav == true_param_3
end

@testset "checks for overrides" begin
    full_param_set = CP.create_parameter_struct(
        Float64;
        override_file = joinpath(@__DIR__, "toml", "override_typos.toml"),
        dict_type = "name",
    )
    mod = "test_module_name"
    CP.get_parameter_values!(full_param_set, "light_speed", mod)

    mktempdir(@__DIR__) do path
        logfilepath3 = joinpath(path, "log_file_test_3.toml")
        @test_logs (:warn,) CP.log_parameter_information(
            full_param_set,
            logfilepath3,
        )
        @test_throws ErrorException CP.log_parameter_information(
            full_param_set,
            logfilepath3,
            strict = true,
        )
    end
end
