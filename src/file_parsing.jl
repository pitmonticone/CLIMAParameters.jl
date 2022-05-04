using TOML
using DocStringExtensions

export ParamDict
export float_type,
    get_parameter_values!,
    get_parameter_values,
    log_parameter_information,
    create_parameter_struct

"""
    ParamDict{T, FT}

structure to hold information read-in from TOML file, as well as a parametrization type `FT`
# Constructors

    ParamDict(
        data::Dict,
        dict_type::String,
        override_dict::Union{Nothing,Dict}
    )

# Fields

$(DocStringExtensions.FIELDS)

"""
struct ParamDict{T,FT <: Symbol}
    "dictionary representing a default/merged parameter TOML file"
    data::Dict
    "either a nothing, or a dictionary representing an override parameter TOML file"
    override_dict::Union{Nothing,Dict}
end
ParamDict{FT}(args...) where {FT} =
    ParamDict{:alias, FT}(args...)

"""
    float_type(::ParamDict{FT}) where {FT}

obtains the type `FT` from `ParamDict{FT}`.
"""
float_type(::ParamDict{T,FT}) where {T,FT} = FT

function Base.iterate(pd::ParamDict{:alias})
    it = iterate(pd.data)
    if !isnothing(it)
        return (Pair(it[1].second["alias"],it[1].second),it[2])
    end
    return nothing
end

function Base.iterate(pd::ParamDict{:alias}, state)
    it = iterate(pd.data,state)
    if !isnothing(it)
        return (Pair(it[1].second["alias"],it[1].second),it[2])
    end
    return nothing
end

Base.iterate(pd::ParamDict{T,FT}, state) where {T,FT} =
    Base.iterate(pd.data, state)

"""
    log_component!(
        param_set::ParamDict,
        names,
        component
    )

Adds a new key,val pair: `("used_in",component)` to each
named parameter in `param_set`. Appends a new val: `component`
if "used_in" key exists.
"""
function log_component!(data::ParamDict{:alias,FT},names,component) where {FT}
    component_key = "used_in"
    c = String(Symbol(component))
    for name in names
        for (key,val) in data
            name ≠ val["alias"] && continue
            data[key][component_key] = if component_key in keys(data[key])
                unique([data[key][component_key]...,c])
            else
                [c]
            end
        end
    end
end
function log_component!(data::ParamDict{T, FT},names,component) where {T, FT}
    component_key = "used_in"
    c = String(Symbol(component))
     for name in names
        for (key,val) in data
            name ≠ key && continue
            data[key][component_key] = if component_key in keys(data[key])
                unique([data[key][component_key]...,c])
            else
                [c]
            end
        end
     end
end


"""
    get_values(param_set::ParamDict, names)

gets the `value` of the named parameters.
"""
function get_values(pd::ParamDict{:alias,FT}, names) where {FT}

    ret_values = []
    for name in names
        for (key,toml_entry) in pd.data
            name ≠ toml_entry["alias"] && continue
            param_value = toml_entry["value"]
            if eltype(param_value) != FT
                push!(ret_values, map(FT, param_value))
            else
                push!(ret_values, param_value)
            end
        end
    end
    return ret_values
end
function get_values(pd::ParamDict{T,FT}, names) where {FT}
    ret_values = []
    for name in names
        param_value = pd.data[name]["value"]
        if eltype(param_value) != FT
            push!(ret_values, map(FT, param_value))
        else
            push!(ret_values, param_value)
        end
    end
    return ret_values
end

"""
    get_parameter_values!(
        param_set::ParamDict,
        names,
        component;
        log_component=true
    )

(Note the `!`) Gets the parameter values,
and logs the component (if `log_component=true`)
where parameters are used.
"""
function get_parameter_values!(
        param_set::ParamDict,
        names,
        component;
        log_component=true
    )
    names_vec = (typeof(names) <: AbstractVector) ? names : [names]

    if log_component
        log_component!(param_set,names_vec,component)
    end
    if (typeof(names) <: AbstractVector)
        return get_values(param_set,names_vec)
    else
        return get_values(param_set,names_vec)[1]
    end
end

"""
    get_parameter_values(param_set::ParamDict, names)

Gets the parameter values only.
"""
get_parameter_values(param_set::ParamDict, names) =
    get_parameter_values!(param_set, names, nothing, log_component=false)

"""
    check_override_parameter_usage(
        param_set::ParamDict,
        warn_else_error
    )

Checks if parameters in the ParamDict.override_dict
have the key "used_in" (i.e. were these parameters
used within the model run).
Throws warnings in each where
parameters are not used. Also throws an error if
`warn_else_error` is not "warn"`.
"""
function check_override_parameter_usage(param_set::ParamDict, warn_else_error)
    if !(isnothing(param_set.override_dict))
        flag_error = !(warn_else_error == "warn")
        component_key = "used_in" # must agree with key above
        for (key,val) in param_set.override_dict
            logged_val = param_set.data[key]
            if ~(component_key in keys(logged_val)) #as val is a Dict
                msg = ""
                msg *= "key $key is present in parameter file, \n"
                msg *= "but not used in the simulation. Typically this\n"
                msg *= "is due to a mismatch in parameter name in toml and in source."
                @warn(msg)
            end
        end
        if flag_error
            @error("At least one override parameter set and not used in simulation")
            throw(ErrorException("Halting simulation due to unused parameters."
                                 * "\n Typically this is due to a typo in the parameter name."
                                 * "\n change warn_else_error flag to \"warn\" to prevent this causing an exception"))
        end
    end
end

"""
    write_log_file(param_set::ParamDict, filepath)

Writes a log file of all used parameters of
`param_set` at the `filepath`. This file can
be used to rerun the experiment.
"""
function write_log_file(param_set::ParamDict, filepath)
    component_key = "used_in"
    used_parameters = Dict()
    for (key,val) in param_set.data
        if ~(component_key in keys(val))
            used_parameters[key] = val
        end
    end
    open(filepath, "w") do io
        TOML.print(io, used_parameters)
    end
end


"""
    log_parameter_information(
        param_set::ParamDict,
        filepath;
        warn_else_error = "warn"
    )

Writes the parameter log file at `filepath`;
checks that override parameters are all used.
"""
function log_parameter_information(
        param_set::ParamDict,
        filepath;
        warn_else_error = "warn"
    )
    #[1.] write the parameters to log file
    write_log_file(param_set,filepath)
    #[2.] send warnings or errors if parameters were not used
    check_override_parameter_usage(param_set,warn_else_error)
end


"""
    merge_override_default_values(
        override_param_struct::ParamDict,
        default_param_struct::ParamDict
    )

Combines the `default_param_struct` with the
`override_param_struct`, precedence is given
to override information.
"""
function merge_override_default_values(
        override_param_struct::ParamDict{T, FT},
        default_param_struct::ParamDict{T, FT}
    ) where {T, FT}
    data = default_param_struct.data
    dict_type = default_param_struct.dict_type
    override_dict = override_param_struct.override_dict
    for (key, val) in override_param_struct.data
        if ~(key in keys(data))
            data[key] = val
        else
            for (kkey,vval) in val # as val is a Dict too
                data[key][kkey] = vval
            end
        end
    end
    return ParamDict{T, FT}(data, dict_type, override_dict)
end

"""
    create_parameter_struct(
        path_to_override,
        path_to_default;
        dict_type="alias",
        float_type=Float64
    )

Creates a `ParamDict{float_type}` struct, by reading
and merging upto two TOML files with override information
taking precedence over default information.
"""
function create_parameter_struct(
        path_to_override,
        path_to_default;
        dict_type="alias",
        float_type=Float64
    )
    return ParamDict{float_type}(TOML.parsefile(path_to_default), dict_type, nothing)
end
function create_parameter_struct(
        path_to_override,
        path_to_default;
        dict_type="alias",
        float_type=Float64
    )
    #if there isn't  an override file take defaults
    if isnothing(path_to_override)
        return ParamDict{float_type}(TOML.parsefile(path_to_default), dict_type, nothing)
    else
        try
            override_param_struct = ParamDict{float_type}(TOML.parsefile(path_to_override), dict_type, TOML.parsefile(path_to_override))
            default_param_struct = ParamDict{float_type}(TOML.parsefile(path_to_default), dict_type, nothing)

            #overrides the defaults where they clash
            return merge_override_default_values(override_param_struct, default_param_struct)
        catch
            @warn("Error in building from parameter file: "*"\n " * path_to_override * " \n instead, created using defaults from CLIMAParameters...")
            return ParamDict{float_type}(TOML.parsefile(path_to_default), dict_type, nothing)
        end
    end

end


"""
    create_parameter_struct(path_to_override; dict_type="alias", float_type=Float64)

a single filepath is assumed to be the override file, defaults are obtained from the CLIMAParameters defaults list.
"""
function create_parameter_struct(path_to_override; dict_type="alias", float_type=Float64)
    #pathof finds the CLIMAParameters.jl/src/ClimaParameters.jl location
    path_to_default = joinpath(splitpath(pathof(CLIMAParameters))[1:end-1]...,"parameters.toml")
    return create_parameter_struct(
        path_to_override,
        path_to_default,
        dict_type=dict_type,
        float_type=float_type,
    )
end

"""
    create_parameter_struct(; dict_type="alias", float_type=Float64)

when no filepath is provided, all parameters are created from CLIMAParameters defaults list.
"""
function create_parameter_struct(; dict_type="alias", float_type=Float64)
    return create_parameter_struct(
        nothing,
        dict_type=dict_type,
        float_type=float_type,
    )
end

