#pip install matplotlib numpy pyjion imageio PyOpenGL glfw
#conda install pytorch torchvision torchaudio pytorch-cuda=11.7 -c pytorch -c nvidia

import sys
import os
import numpy as np
import torch
import pyjion #conflict with matplotlib
#pyjion.enable()

device = torch.device("cuda") if torch.cuda.is_available() else torch.device("mps") if torch.backends.mps.is_available() else torch.device("cpu")
os.environ["KMP_DUPLICATE_LIB_OK"]="TRUE"

s_gpu_tensor_cache = {}
vm_gpu_tensor_cache = {}

cpu_zeros_tensor_cache = {}
cpu_ones_tensor_cache = {}
gpu_zeros_tensor_cache = {}
gpu_ones_tensor_cache = {}

cpu_zero_tensor = torch.as_tensor(0.0, dtype=torch.float64)
gpu_zero_tensor = torch.as_tensor(0.0, dtype=torch.float64, device=device)
cpu_zero2_tensor = torch.as_tensor([0.0, 0.0], dtype=torch.float64)
gpu_zero2_tensor = torch.as_tensor([0.0, 0.0], dtype=torch.float64, device=device)

cpu_one_tensor = torch.as_tensor(1.0, dtype=torch.float64)
gpu_one_tensor = torch.as_tensor(1.0, dtype=torch.float64, device=device)

class TensorPools:
    def __init__(self) -> None:
        self.pools = {}
        self.allocs = {}
    def New(self, type, n, dim = None, dim2 = None):
        pools_by_type = self.pools.get(type)
        if pools_by_type is None:
            pools_by_type = {}
            self.pools[type] = pools_by_type
        if (dim is None or dim == 1) and dim2 is None:
            pool = pools_by_type.get(n)
            if pool is not None and len(pool) > 0:
                return pool.pop()
            t = torch.empty([n], dtype=type, device=device)
            self.Record(type, t, n, dim, dim2)
            return t
        elif dim2 is None:
            k = (n, dim)
            pool = pools_by_type.get(k)
            if pool is not None and len(pool) > 0:
                return pool.pop()
            t = torch.empty((n, dim), dtype=type, device=device)
            self.Record(type, t, n, dim, dim2)
            return t
        else:
            k = (n, dim, dim2)
            pool = pools_by_type.get(k)
            if pool is not None and len(pool) > 0:
                return pool.pop()
            t = torch.empty((n, dim, dim2), dtype=type, device=device)
            self.Record(type, t, n, dim, dim2)
            return t
    def Record(self, type, t, n, dim = None, dim2 = None):
        allocs_by_type = self.allocs.get(type)
        if allocs_by_type is None:
            allocs_by_type = {}
            self.allocs[type] = allocs_by_type
        if (dim is None or dim == 1) and dim2 is None:
            k = (n, 0, 0)
            allocs = allocs_by_type.get(k)
            if allocs is None:
                allocs = []
                allocs_by_type[k] = allocs
            allocs.append(t)
        elif dim2 is None:
            k = (n, dim, 0)
            allocs = allocs_by_type.get(k)
            if allocs is None:
                allocs = []
                allocs_by_type[k] = allocs
            allocs.append(t)
        else:
            k = (n, dim, dim2)
            allocs = allocs_by_type.get(k)
            if allocs is None:
                allocs = []
                allocs_by_type[k] = allocs
            allocs.append(t)
    def RecycleAll(self):
        for type, allocs in self.allocs.items():
            for ks, t in allocs.items():
                if ks[1] == 0 and ks[2] == 0:
                    k = ks[0]
                    pool = self.pools.get(k)
                    if pool is None:
                        pool = []
                        self.pools[k] = pool
                    for v in t:
                        pool.append(v)
                elif ks[2] == 0:
                    k = (ks[0], ks[1])
                    pool = self.pools.get(k)
                    if pool is None:
                        pool = []
                        self.pools[k] = pool
                    for v in t:
                        pool.append(v)
                else:
                    k = (ks[0], ks[1], ks[2])
                    pool = self.pools.get(k)
                    if pool is None:
                        pool = []
                        self.pools[k] = pool
                    for v in t:
                        pool.append(v)
        self.allocs.clear()

tensor_pools = TensorPools()

pool_N = {}

def poolGetN(num):
    arr = pool_N.get(num)
    if arr is None:
        arr = torch.arange(0, num, 1, dtype=torch.int64)
        pool_N[num] = arr
    return arr

def tuple_get_outparam(v, index):
    return v[index]
def tuple_get_retval(v):
    return v[0][0]
def tuple_get_value(v, index):
    return v[index]
def tuple_get_lastval(v):
    return v[len(v)-1]

def maybe_svm_array(v):
    return type(v) == torch.Tensor and v.dim() >= 1 and len(v) > 4
def maybe_scalar_array(v):
    return type(v) == torch.Tensor and v.dim() == 1 and len(v) > 4
def maybe_vec_mat_array(v):
    return type(v) == torch.Tensor and v.dim() >= 2 and len(v) > 4

def new_zero_tensor(n, dim = None, dim2 = None):
    t = tensor_pools.New(torch.float64, n, dim, dim2)
    t[...] = 0
    return t
def new_zero_int_tensor(n, dim = None, dim2 = None):
    t = tensor_pools.New(torch.int64, n, dim, dim2)
    t[...] = 0
    return t
def new_false_tensor(n, dim = None, dim2 = None):
    t = tensor_pools.New(torch.bool, n, dim, dim2)
    t[...] = False
    return t

def get_s_key(v):
    if type(v) == torch.Tensor:
        v = v.item()
    return type(v), v
def get_vm_key(v):
    if type(v) == torch.Tensor:
        dimn = v.dim()
        ty = None
        if dimn == 2:
            keys = []
            for elem in v:
                keys.append(tuple(elem))
            t = tuple(keys)
            return type(v[0][0]), t, 2
        else:
            return type(v[0]), tuple(v.tolist()), 1
    elif type(v[0]) == list:
        keys = []
        for elem in v:
            keys.append(tuple(elem))
        t = tuple(keys)
        return type(v[0][0]), t, 2
    else:
        return type(v[0]), tuple(v), 1
def get_s_gpu_tensor(v):
    '''
    if type(v) != torch.Tensor:
        return torch.as_tensor(v, device=device)
    elif not v.is_cuda:
        return v.cuda()
    return v
    '''
    if type(v) == torch.Tensor and v.is_cuda:
        return v
    caches = s_gpu_tensor_cache
    tkey, vkey = get_s_key(v)
    cache = caches.get(tkey)
    if cache is None:
        cache = {}
        caches[tkey] = cache
    nv = cache.get(vkey)
    if nv is not None:
        return nv
    if type(v) != torch.Tensor:
        nv = torch.as_tensor(v, device=device)
    else:
        nv = v.cuda()
    cache[vkey] = nv
    return nv

def get_vm_gpu_tensor(v):
    '''
    if type(v) != torch.Tensor:
        return torch.as_tensor(v, device=device)
    elif not v.is_cuda:
        return v.cuda()
    return v
    '''
    if type(v) == torch.Tensor and v.is_cuda:
        return v
    caches = vm_gpu_tensor_cache
    tkey, vkey, vdim = get_vm_key(v)
    cache = caches.get(tkey)
    if cache is None:
        cache = {}
        caches[tkey] = cache
    nv = cache.get(vkey)
    if nv is not None:
        return nv
    if type(v) != torch.Tensor:
        nv = torch.as_tensor(v, device=device)
        cache[vkey] = nv
    else:
        nv = v.cuda()
        if nv.dim() == vdim:
            cache[vkey] = nv
    return nv

def get_cpu_zeros(count):
    v = cpu_zeros_tensor_cache.get(count)
    if v is not None:
        return v
    zeros = torch.zeros(count)
    cpu_zeros_tensor_cache[count] = zeros
    return zeros
def get_cpu_ones(count):
    v = cpu_ones_tensor_cache.get(count)
    if v is not None:
        return v
    ones = torch.ones(count)
    cpu_ones_tensor_cache[count] = ones
    return ones
def get_gpu_zeros(count):
    v = gpu_zeros_tensor_cache.get(count)
    if v is not None:
        return v
    zeros = torch.zeros(count, device=device)
    gpu_zeros_tensor_cache[count] = zeros
    return zeros
def get_gpu_ones(count):
    v = gpu_ones_tensor_cache.get(count)
    if v is not None:
        return v
    ones = torch.ones(count, device=device)
    gpu_ones_tensor_cache[count] = ones
    return ones

def get_cpu_value(v):
    if type(v) == torch.Tensor and v.is_cuda:
        return v.cpu()
    return v
def get_gpu_value(v):
    if type(v) == torch.Tensor and not v.is_cuda:
        return v.cuda()
    return v

def change_to_same_f64(a, b):
    if a.dtype != torch.float64:
        a = a.double()
    if b.dtype != torch.float64:
        b = b.double()
    return a, b
def change_to_f64(v):
    if v.dtype != torch.float64:
        v = v.double()
    return v

def h_clamp_v_v_v(v, a, b):
    v = get_gpu_value(v)
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.clip(v, a, b)
def h_clamp_n_n_n(v, a, b):
    v = get_s_gpu_tensor(v)
    a = get_s_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return torch.clip(v, a, b)
def h_clamp_v_n_n(v, a, b):
    v = get_gpu_value(v)
    a = get_s_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return torch.clip(v, a, b)
def h_clamp_t_n_n_n(v, a, b):
    v = get_gpu_value(v)
    a = get_s_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return torch.clip(v, a, b)
def h_clamp_t_n_n_t_n(v, a, b):
    v = get_gpu_value(v)
    a = get_s_gpu_tensor(a)
    b = get_gpu_value(b)
    return torch.clip(v, a, b)
def h_clamp_t_n_t_n_t_n(v, a, b):
    v = get_gpu_value(v)
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.clip(v, a, b)
def h_clamp_t_v_n_n(v, a, b):
    v = get_gpu_value(v)
    a = get_s_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return torch.clip(v, a, b)
def h_clamp_t_v_v_v(v, a, b):
    v = get_gpu_value(v)
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.clip(v, a, b)

def h_lerp_n_n_n(a, b, h):
    return (1 - h) * a + h * b
def h_lerp_v_v_n(a, b, h):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    return (1 - h) * a + h * b
def h_lerp_v_v_v(a, b, h):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    return (1 - h) * a + h * b
def h_lerp_v_v_t_n(a, b, h):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    a = torch.broadcast_to(a, (len(h), len(a)))
    b = torch.broadcast_to(b, (len(h), len(b)))
    return ((1 - h) * a.T + h * b.T).T
def h_lerp_v_t_v_t_n(a, b, h):
    a = get_gpu_value(a)
    b = get_gpu_value(b)    
    h = get_gpu_value(h)
    a = torch.broadcast_to(a, (len(b), len(a)))
    return ((1 - h) * a.T + h * b.T).T
def h_lerp_t_v_v_t_n(a, b, h):
    a = get_gpu_value(a)
    b = get_gpu_value(b)    
    h = get_gpu_value(h)
    b = torch.broadcast_to(b, (len(a), len(b)))
    return ((1 - h) * a.T + h * b.T).T
def h_lerp_v_v_t_v(a, b, h):
    r = ((1 - h) * a + h * b)
    return r
def h_lerp_n_n_t_n(a, b, h):
    return (1 - h) * a + h * b
def h_lerp_t_n_t_n_t_n(a, b, h):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    return (1 - h) * a + h * b
def h_lerp_t_n_t_n_n(a, b, h):
    h = torch.broadcast_to(get_s_gpu_tensor(h), [len(a)])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    return (1 - h) * a + h * b
def h_lerp_n_t_n_t_n(a, b, h):
    a = torch.broadcast_to(get_s_gpu_tensor(a), [len(b)])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    return (1 - h) * a + h * b
def h_lerp_t_n_n_t_n(a, b, h):
    b = torch.broadcast_to(get_s_gpu_tensor(b), [len(a)])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    return (1 - h) * a + h * b
def h_lerp_t_n_n_n(a, b, h):
    b = torch.broadcast_to(get_s_gpu_tensor(b), [len(a)])
    h = torch.broadcast_to(get_s_gpu_tensor(h), [len(a)])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    return (1 - h) * a + h * b
def h_lerp_n_t_n_n(a, b, h):
    a = torch.broadcast_to(get_s_gpu_tensor(a), [len(b)])
    h = torch.broadcast_to(get_s_gpu_tensor(h), [len(b)])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    return (1 - h) * a + h * b
def h_lerp_t_v_t_v_t_v(a, b, h):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    return (1 - h) * a + h * b
def h_lerp_t_v_v_t_v(a, b, h):
    m = len(a)
    n = len(b)
    b = torch.broadcast_to(get_vm_gpu_tensor(b), (m, n))
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    return (1 - h) * a + h * b
def h_lerp_t_v_t_v_v(a, b, h):
    m = len(a)
    n = len(h)
    h = torch.broadcast_to(get_vm_gpu_tensor(h), (m, n))
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    return (1 - h) * a + h * b
def h_lerp_v_t_v_t_v(a, b, h):
    m = len(h)
    n = len(a)
    a = torch.broadcast_to(get_vm_gpu_tensor(a), (m, n))
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    return (1 - h) * a + h * b
def h_lerp_t_v_v_v(a, b, h):
    m = len(a)
    b = torch.broadcast_to(get_vm_gpu_tensor(b), (m, len(b)))
    h = torch.broadcast_to(get_vm_gpu_tensor(h), (m, len(h)))
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    return (1 - h) * a + h * b
def h_lerp_t_v_t_v_t_n(a, b, h):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    return ((1 - h) * a.T + h * b.T).T
def h_lerp_t_v_t_v_n(a, b, h):
    h = torch.broadcast_to(get_s_gpu_tensor(h), [len(a)])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    return ((1 - h) * a.T + h * b.T).T
def h_lerp_t_v_v_n(a, b, h):
    h = torch.broadcast_to(get_s_gpu_tensor(h), [len(a)])
    b = torch.broadcast_to(b, (len(a), len(b)))
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    h = get_gpu_value(h)
    return ((1 - h) * a.T + h * b.T).T

def h_smoothstep_n_n_n(a, b, v):
    a = get_s_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    v = get_s_gpu_tensor(v)
    t = (v - a) / (b - a)
    t = torch.clip(t, gpu_zero_tensor, gpu_one_tensor)
    return t * t * (3 - 2 * t)
def h_smoothstep_n_n_v(a, b, v):
    a = get_s_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    v = get_vm_gpu_tensor(v)
    t = (v - a) / (b - a)
    t = torch.clip(t, gpu_zero_tensor, gpu_one_tensor)
    return t * t * (3 - 2 * t)
def h_smoothstep_n_n_t_n(a, b, v):
    a = torch.broadcast_to(get_s_gpu_tensor(a), [len(v)])
    b = torch.broadcast_to(get_s_gpu_tensor(b), [len(v)])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    v = get_gpu_value(v)
    t = (v - a) / (b - a)
    t = torch.clip(t, gpu_zero_tensor, gpu_one_tensor)
    return t * t * (3 - 2 * t)
def h_smoothstep_n_t_n_t_n(a, b, v):
    a = torch.broadcast_to(get_s_gpu_tensor(a), [len(v)])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    v = get_gpu_value(v)
    t = (v - a) / (b - a)
    t = torch.clip(t, gpu_zero_tensor, gpu_one_tensor)
    return t * t * (3 - 2 * t)
def h_smoothstep_t_n_n_t_n(a, b, v):
    b = torch.broadcast_to(get_s_gpu_tensor(b), [len(v)])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    v = get_gpu_value(v)
    t = (v - a) / (b - a)
    t = torch.clip(t, gpu_zero_tensor, gpu_one_tensor)
    return t * t * (3 - 2 * t)
def h_smoothstep_n_n_t_v(a, b, v):
    m = len(v)
    n = len(v[0])
    a = torch.broadcast_to(get_s_gpu_tensor(a), (m, n))
    b = torch.broadcast_to(get_s_gpu_tensor(b), (m, n))
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    v = get_gpu_value(v)
    t = (v - a) / (b - a)
    t = torch.clip(t, gpu_zero_tensor, gpu_one_tensor)
    return t * t * (3 - 2 * t)
def h_smoothstep_v_v_t_v(a, b, v):
    m = len(v)
    n = len(a)
    a = torch.broadcast_to(get_vm_gpu_tensor(a), (m, n))
    b = torch.broadcast_to(get_vm_gpu_tensor(b), (m, n))
    t = (v - a) / (b - a)
    t = torch.clip(t, gpu_zero_tensor, gpu_one_tensor)
    return t * t * (3 - 2 * t)
def h_smoothstep_t_n_t_n_t_n(a, b, v):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    v = get_gpu_value(v)
    t = (v - a) / (b - a)
    t = torch.clip(t, gpu_zero_tensor, gpu_one_tensor)
    return t * t * (3 - 2 * t)
def h_smoothstep_t_n_t_n_n(a, b, v):
    v = torch.broadcast_to(get_s_gpu_tensor(v), [len(a)])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    v = get_gpu_value(v)
    t = (v - a) / (b - a)
    t = torch.clip(t, gpu_zero_tensor, gpu_one_tensor)
    return t * t * (3 - 2 * t)

def h_sin_n(v):
    v = get_s_gpu_tensor(v)
    return torch.sin(v)
def h_sin_v(v):
    v = get_gpu_value(v)
    return torch.sin(v)
def h_sin_t_n(v):
    return torch.sin(v)
def h_sin_t_v(v):
    return torch.sin(v)

def h_cos_n(v):
    v = get_s_gpu_tensor(v)
    return torch.cos(v)
def h_cos_v(v):
    v = get_gpu_value(v)
    return torch.cos(v)
def h_cos_t_n(v):
    return torch.cos(v)
def h_cos_t_v(v):
    return torch.cos(v)

def h_asin_n(v):
    return torch.arcsin(v)
def h_asin_v(v):
    return torch.arcsin(v)
def h_asin_t_n(v):
    return torch.arcsin(v)
def h_asin_t_v(v):
    return torch.arcsin(v)

def h_acos_n(v):
    return torch.arccos(v)
def h_acos_v(v):
    return torch.arccos(v)
def h_acos_t_n(v):
    return torch.arccos(v)
def h_acos_t_v(v):
    return torch.arccos(v)

def h_tan_n(v):
    v = get_s_gpu_tensor(v)
    return torch.tan(v)
def h_tan_t_n(v):
    return torch.tan(v)

def h_atan_n(v):
    v = get_s_gpu_tensor(v)
    return torch.arctan(v)
def h_atan_t_n(v):
    return torch.arctan(v)
def h_atan2_n_n(y, x):
    y = get_s_gpu_tensor(y)
    x = get_s_gpu_tensor(x)
    return torch.arctan2(y, x)
def h_atan2_t_n_t_n(y, x):
    return torch.arctan2(y, x)
def h_radians_n(v):
    v = get_s_gpu_tensor(v)
    return torch.deg2rad(v)
def h_radians_t_n(v):
    return torch.deg2rad(v)

def h_degrees_n(v):
    v = get_s_gpu_tensor(v)
    return torch.rad2deg(v)
def h_degrees_t_n(v):
    return torch.rad2deg(v)

def h_frac_n(v):
    v = get_s_gpu_tensor(v)
    return v - torch.floor(v)
def h_frac_v(v):
    return v - torch.floor(v)
def h_frac_t_n(v):
    return v - torch.floor(v)
def h_frac_t_v(v):
    return v - torch.floor(v)

def h_fmod_n_n(v1, v2):
    v1 = get_s_gpu_tensor(v1)
    v2 = get_s_gpu_tensor(v2)
    return torch.fmod(v1, v2)
def h_fmod_n_v(v1, v2):
    return torch.fmod(v1, v2)
def h_fmod_v_n(v1, v2):
    return torch.fmod(v1, v2)
def h_fmod_v_v(v1, v2):
    v1 = get_gpu_value(v1)
    v2 = get_gpu_value(v2)
    v1, v2 = change_to_same_f64(v1, v2)
    return torch.fmod(v1, v2)
def h_fmod_t_n_n(v1, v2):
    return torch.fmod(v1, v2)
def h_fmod_t_v_n(v1, v2):
    return torch.fmod(v1, v2)
def h_fmod_t_v_v(v1, v2):
    v1 = get_gpu_value(v1)
    v2 = get_gpu_value(v2)
    return torch.fmod(v1, v2)
def h_fmod_n_t_n(v1, v2):
    return torch.fmod(v1, v2)
def h_fmod_n_t_v(v1, v2):
    return torch.fmod(v1, v2)
def h_fmod_v_t_v(v1, v2):
    return torch.fmod(v1, v2)
def h_fmod_t_n_t_n(v1, v2):
    return torch.fmod(v1, v2)
def h_fmod_t_v_t_v(v1, v2):
    return torch.fmod(v1, v2)

def h_dot_n_n(v1, v2):
    v1 = get_s_gpu_tensor(v1)
    v2 = get_s_gpu_tensor(v2)
    return torch.dot(v1, v2)
def h_dot_v_v(v1, v2):
    v1 = get_gpu_value(v1)
    v2 = get_gpu_value(v2)
    v1, v2 = change_to_same_f64(v1, v2)
    return torch.dot(v1, v2)
def h_dot_t_n_n(v1, v2):
    return torch.dot(v1, v2)
def h_dot_t_v_v(v1, v2):
    v1 = get_gpu_value(v1)
    v2 = get_vm_gpu_tensor(v2)
    v1, v2 = change_to_same_f64(v1, v2)
    return torch.linalg.vecdot(v1, v2)
def h_dot_v_t_v(v1, v2):
    v1 = get_gpu_value(v1)
    v2 = get_gpu_value(v2)
    v1, v2 = change_to_same_f64(v1, v2)
    return torch.linalg.vecdot(v1, v2)
def h_dot_t_n_t_n(v1, v2):
    v1 = get_gpu_value(v1)
    v2 = get_gpu_value(v2)
    return torch.dot(v1, v2)
def h_dot_t_v_t_v(v1, v2):
    v1 = get_gpu_value(v1)
    v2 = get_gpu_value(v2)
    v1, v2 = change_to_same_f64(v1, v2)
    return torch.linalg.vecdot(v1, v2)

def h_reflect_v_v(v1, v2):
    v1 = get_gpu_value(v1)
    v2 = get_gpu_value(v2)
    v1, v2 = change_to_same_f64(v1, v2)
    dot = torch.dot(v1, v2)
    return v1 - 2 * dot * v2
def h_reflect_t_v_v(v1, v2):
    v1 = get_gpu_value(v1)
    v2 = get_gpu_value(v2)
    v1, v2 = change_to_same_f64(v1, v2)
    dot = torch.linalg.vecdot(v1, v2)
    dot = dot.reshape(len(dot), 1)
    _2_dot_v2 = torch.mul(dot, v2) * 2.0
    return v1 - _2_dot_v2
def h_reflect_v_t_v(v1, v2):
    v1 = get_gpu_value(v1)
    v2 = get_gpu_value(v2)
    v1, v2 = change_to_same_f64(v1, v2)
    dot = torch.linalg.vecdot(v1, v2)
    _2_dot_v2 = torch.mul(dot, v2.T).T * 2.0
    return v1 - _2_dot_v2
def h_reflect_t_v_t_v(v1, v2):
    v1 = get_gpu_value(v1)
    v2 = get_gpu_value(v2)
    v1, v2 = change_to_same_f64(v1, v2)
    dot = torch.linalg.vecdot(v1, v2)
    _2_dot_v2 = torch.mul(dot, v2.T).T * 2.0
    return v1 - _2_dot_v2

def h_refract_v_v_n(I, N, eta):
    m = len(I)
    I = get_vm_gpu_value(I)
    N = get_vm_gpu_value(N)
    eta = get_s_gpu_tensor(eta)
    dotval = h_dot_v_v(N, I)
    k = gpu_one_tensor - eta * eta * (gpu_one_tensor - dotval * dotval)
    R0 = torch.broadcast_to(gpu_zero_tensor, [m])
    bvs = k >= gpu_zero_tensor
    bvs = torch.broadcast_to(get_s_gpu_tensor(bvs), [m])
    R = torch.where(bvs, eta * I - (eta * dotval + torch.sqrt(torch.abs(k))) * N, R0)
    return R
def h_refract_t_v_t_v_n(I, N, eta):
    m = len(I)
    n = len(I[0])
    I = get_gpu_value(I)
    N = get_gpu_value(N)
    eta = get_s_gpu_tensor(eta)
    dotval = h_dot_t_v_t_v(N, I)
    k = gpu_one_tensor - eta * eta * (gpu_one_tensor - dotval * dotval)
    R0 = torch.broadcast_to(gpu_zero_tensor, (m, n))
    bvs = k >= gpu_zero_tensor
    bvs = torch.broadcast_to(bvs, (n, m)).T
    R = torch.where(bvs, eta * I - ((eta * dotval + torch.sqrt(torch.abs(k))) * N.T).T, R0)
    return R
def h_refract_t_v_t_v_t_n(I, N, eta):
    m = len(I)
    n = len(I[0])
    I = get_gpu_value(I)
    N = get_gpu_value(N)
    eta = get_gpu_value(eta)
    dotval = h_dot_t_v_t_v(N, I)
    k = gpu_one_tensor - eta * eta * (gpu_one_tensor - dotval * dotval)
    R0 = torch.broadcast_to(gpu_zero_tensor, (m, n))
    bvs = k >= gpu_zero_tensor
    bvs = torch.broadcast_to(bvs, (n, m)).T
    R = torch.where(bvs, (eta * I.T).T - ((eta * dotval + torch.sqrt(torch.abs(k))) * N.T).T, R0)
    return R

def h_floor_n(v):
    v = get_s_gpu_tensor(v)
    return torch.floor(v)
def h_floor_v(v):
    return torch.floor(v)
def h_floor_t_n(v):
    return torch.floor(v)
def h_floor_t_v(v):
    return torch.floor(v)

def h_ceil_n(v):
    v = get_s_gpu_tensor(v)
    return torch.ceil(v)
def h_ceil_v(v):
    return torch.ceil(v)
def h_ceil_t_n(v):
    return torch.ceil(v)
def h_ceil_t_v(v):
    return torch.ceil(v)

def h_round_n(v):
    v = get_s_gpu_tensor(v)
    return torch.round(v)
def h_round_v(v):
    return torch.round(v)
def h_round_t_n(v):
    return torch.round(v)
def h_round_t_v(v):
    return torch.round(v)

def h_length_n(v):
    return torch.abs(v)
def h_length_t_n(v):
    return torch.abs(v)
def h_length_v(v):
    return torch.sqrt(torch.sum(torch.pow(v, 2)))
def h_length_t_v(v):
    return torch.sqrt(torch.linalg.vecdot(v, v))

def h_distance_v_v(v1, v2):
    v = v1 - v2
    v = get_vm_gpu_tensor(v)
    return torch.sqrt(torch.sum(torch.power(v, 2)))
def h_distance_t_v_v(v1, v2):
    v1 = get_gpu_value(v1)
    v2 = get_gpu_value(v2)
    v = v1 - v2
    return torch.sqrt(torch.linalg.vecdot(v, v))
def h_distance_v_t_v(v1, v2):
    v1 = get_gpu_value(v1)
    v2 = get_gpu_value(v2)
    v = v1 - v2
    return torch.sqrt(torch.linalg.vecdot(v, v))
def h_distance_t_v_t_v(v1, v2):
    v1 = get_gpu_value(v1)
    v2 = get_gpu_value(v2)
    v = v1 - v2
    return torch.sqrt(torch.linalg.vecdot(v, v))

def h_normalize_v(v):
    return v / (torch.linalg.norm(v) + sys.float_info.epsilon)
def h_normalize_t_v(v):
    return (v.T / (torch.linalg.norm(v, axis=1) + sys.float_info.epsilon)).T
def h_cross_v_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    a, b = change_to_same_f64(a, b)
    return torch.cross(a, b)
def h_cross_t_v_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    a, b = change_to_same_f64(a, b)
    m = len(a)
    n = len(b)
    b = torch.broadcast_to(b, (m, n))
    return torch.cross(a, b)
def h_cross_v_t_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    a, b = change_to_same_f64(a, b)
    m = len(b)
    n = len(a)
    a = torch.broadcast_to(a, (m, n))
    return torch.cross(a, b)
def h_cross_t_v_t_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    a, b = change_to_same_f64(a, b)
    return torch.cross(a, b)

def h_sqrt_n(v):
    v = get_s_gpu_tensor(v)
    return torch.sqrt(v)
def h_sqrt_v(v):
    v = get_gpu_value(v)
    return torch.sqrt(v)
def h_sqrt_t_n(v):
    v = get_gpu_value(v)
    return torch.sqrt(v)
def h_sqrt_t_v(v):
    return torch.sqrt(v)

def h_pow_n_n(v, n):
    v = get_s_gpu_tensor(v)
    n = get_s_gpu_tensor(n)
    return torch.pow(v, n)
def h_pow_v_v(v, n):
    v = get_gpu_value(v)
    n = get_gpu_value(n)
    return torch.pow(v, n)
def h_pow_v_n(v, n):
    v = get_gpu_value(v)
    n = get_gpu_value(n)
    return torch.pow(v, n)
def h_pow_t_n_n(v, n):
    return torch.pow(v, n)
def h_pow_n_t_n(v, n):
    return torch.pow(v, n)
def h_pow_t_n_t_n(v, n):
    return torch.pow(v, n)
def h_pow_t_v_v(v, n):
    v = get_gpu_value(v)
    n = get_gpu_value(n)
    return torch.pow(v, n)

def h_log_n(v):
    v = get_s_gpu_tensor(v)
    return torch.log(v)
def h_log_v(v):
    v = get_vm_gpu_tensor(v)
    return torch.log(v)
def h_log_t_n(v):
    return torch.log(v)
def h_log_t_v(v):
    return torch.log(v)

def h_log2_n(v):
    v = get_s_gpu_tensor(v)
    return torch.log2(v)
def h_log2_v(v):
    v = get_vm_gpu_tensor(v)
    return torch.log2(v)
def h_log2_t_n(v):
    return torch.log2(v)
def h_log2_t_v(v):
    return torch.log2(v)

def h_log10_n(v):
    v = get_s_gpu_tensor(v)
    return torch.log10(v)
def h_log10_v(v):
    v = get_vm_gpu_tensor(v)
    return torch.log10(v)
def h_log10_t_n(v):
    return torch.log10(v)
def h_log10_t_v(v):
    return torch.log10(v)

def h_exp_n(v):
    v = get_s_gpu_tensor(v)
    return torch.exp(v)
def h_exp_v(v):
    v = get_vm_gpu_tensor(v)
    return torch.exp(v)
def h_exp_t_n(v):
    return torch.exp(v)
def h_exp_t_v(v):
    return torch.exp(v)

def h_exp2_n(v):
    v = get_s_gpu_tensor(v)
    return torch.exp2(v)
def h_exp2_v(v):
    v = get_vm_gpu_tensor(v)
    return torch.exp2(v)
def h_exp2_t_n(v):
    return torch.exp2(v)
def h_exp2_t_v(v):
    return torch.exp2(v)
def h_sign_n(v):
    v = get_s_gpu_tensor(v)
    return torch.sign(v)
def h_sign_v(v):
    v = get_vm_gpu_tensor(v)
    return torch.sign(v)
def h_sign_t_n(v):
    return torch.sign(v)
def h_sign_t_v(v):
    return torch.sign(v)

def h_ddx_n(v):
    return get_s_gpu_tensor(0.001)
def h_ddy_n(v):
    return get_s_gpu_tensor(0.001)
def h_ddx_v(v):
    return gpu_zero2_tensor
def h_ddy_v(v):
    return gpu_zero2_tensor
def h_ddx_fine_n(v):
    return gpu_zero_tensor
def h_ddy_fine_n(v):
    return gpu_zero_tensor
def h_ddx_coarse_n(v):
    return gpu_zero_tensor
def h_ddy_coarse_n(v):
    return gpu_zero_tensor
def h_ddx_t_n(v):
    return torch.broadcast_to(get_s_gpu_tensor(0.001), [len(v)])
def h_ddy_t_n(v):
    return torch.broadcast_to(get_s_gpu_tensor(0.001), [len(v)])
def h_ddx_t_v(v):
    return torch.broadcast_to(gpu_zero2_tensor, (len(v), 2))
def h_ddy_t_v(v):
    return torch.broadcast_to(gpu_zero2_tensor, (len(v), 2))
def h_ddx_fine_t_n(v):
    return torch.broadcast_to(gpu_zero_tensor, [len(v)])
def h_ddy_fine_t_n(v):
    return torch.broadcast_to(gpu_zero_tensor, [len(v)])
def h_ddx_coarse_t_n(v):
    return torch.broadcast_to(gpu_zero_tensor, [len(v)])
def h_ddy_coarse_t_n(v):
    return torch.broadcast_to(gpu_zero_tensor, [len(v)])

def h_fwidth_n(v):
    return h_abs_n(h_ddx_n(v)) + h_abs_n(h_ddy_n(v))
def h_fwidth_t_n(v):
    return h_abs_t_n(h_ddx_t_n(v)) + h_abs_t_n(h_ddy_t_n(v))
def h_fwidth_v(v):
    return h_abs_v(h_ddx_v(v)) + h_abs_v(h_ddy_v(v))
def h_fwidth_t_v(v):
    return h_abs_t_v(h_ddx_t_v(v)) + h_abs_t_v(h_ddy_t_v(v))
def h_transpose_m(m):
    return torch.t(m)
def h_transpose_t_m(m):
    return m.transpose(1, 2)

def h_matmul_f2x2_f2(m, v):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    return torch.matmul(m, v)
def h_matmul_f2x2_t_f2(m, v):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    return torch.matmul(m, v.T).T
def h_matmul_t_f2x2_f2(m, v):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    return torch.matmul(m, v.T).T
def h_matmul_t_f2x2_t_f2(m, v):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    r = -torch.matmul(torch.broadcast_to(v, (2, len(v), 2)).transpose(0, 1), m).transpose(0, 1)[0, ...]
    return r
def h_matmul_f2_f2x2(v, m):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    return torch.matmul(v, m)
def h_matmul_t_f2_f2x2(v, m):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    return torch.matmul(v, m)
def h_matmul_t_f2_t_f2x2(v, m):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    return torch.matmul(torch.broadcast_to(v, (2, len(v), 2)).transpose(0, 1), m).transpose(0, 1)[0, ...]
def h_matmul_f3x3_f3(m, v):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    return torch.matmul(m, v)
def h_matmul_f3x3_f3x3(m1, m2):
    m1 = get_gpu_value(m1)
    m2 = get_gpu_value(m2)
    m1, m2 = change_to_same_f64(m1, m2)
    return torch.matmul(m1, m2)
def h_matmul_f3x3_t_f3(m, v):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    r = torch.matmul(m, v.T).T
    return r
def h_matmul_f3_f3x3(v, m):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    return torch.matmul(v, m)
def h_matmul_t_f3_f3x3(v, m):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    return torch.matmul(v, m)
def h_matmul_t_f3_t_f3x3(v, m):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    return torch.matmul(torch.broadcast_to(v, (3, len(v), 3)).transpose(0, 1), m).transpose(0, 1)[0, ...]
def h_matmul_f4x4_f4(m, v):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    return torch.matmul(m, v)
def h_matmul_f4x4_f4x4(m1, m2):
    m1 = get_gpu_value(m1)
    m2 = get_gpu_value(m2)
    m1, m2 = change_to_same_f64(m1, m2)
    return torch.matmul(m1, m2)
def h_matmul_f4x4_t_f4(m, v):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    return torch.matmul(m, v.T).T
def h_matmul_f4_f4x4(v, m):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    return torch.matmul(v, m)
def h_matmul_t_f4_f4x4(v, m):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    return torch.matmul(v, m)
def h_matmul_t_f4_t_f4x4(v, m):
    m = get_gpu_value(m)
    v = get_gpu_value(v)
    m, v = change_to_same_f64(m, v)
    return torch.matmul(torch.broadcast_to(v, (4, len(v), 4)).transpose(0, 1), m).transpose(0, 1)[0, ...]

def h_max_n_n(a, b):
    a = get_s_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return torch.maximum(a, b)
def h_max_v_n(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return torch.maximum(a, b)
def h_max_n_v(a, b):
    a = get_s_gpu_tensor(a)
    b = get_vm_gpu_tensor(b)
    return torch.maximum(a, b)
def h_max_v_v(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_vm_gpu_tensor(b)
    return torch.maximum(a, b)
def h_max_v_t_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.maximum(a, b)
def h_max_t_v_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.maximum(a, b)
def h_max_t_n_n(a, b):
    m = len(a)
    b = torch.broadcast_to(get_s_gpu_tensor(b), [m])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.maximum(a, b)
def h_max_n_t_n(a, b):
    m = len(b)
    a = torch.broadcast_to(get_s_gpu_tensor(a), [m])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.maximum(a, b)
def h_max_t_n_t_n(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.maximum(a, b)
def h_max_t_v_t_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.maximum(a, b)
def h_max_t_v_n(a, b):
    m = len(a)
    n = len(a[0])
    b = torch.broadcast_to(get_s_gpu_tensor(b), (m, n))
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.maximum(a, b)
def h_max_n_t_v(a, b):
    return torch.maximum(a, b)

def h_min_n_n(a, b):
    a = get_s_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return torch.minimum(a, b)
def h_min_v_n(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return torch.minimum(a, b)
def h_min_n_v(a, b):
    a = get_s_gpu_tensor(a)
    b = get_vm_gpu_tensor(b)
    return torch.minimum(a, b)
def h_min_v_v(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_vm_gpu_tensor(b)
    return torch.minimum(a, b)
def h_min_v_t_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.minimum(a, b)
def h_min_t_v_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.minimum(a, b)
def h_min_t_n_n(a, b):
    b = torch.broadcast_to(get_s_gpu_tensor(b), [len(a)])
    b = get_gpu_value(b)
    return torch.minimum(a, b)
def h_min_n_t_n(a, b):
    a = torch.broadcast_to(get_s_gpu_tensor(a), [len(b)])
    a = get_gpu_value(a)
    return torch.minimum(a, b)
def h_min_t_n_t_n(a, b):
    return torch.minimum(a, b)
def h_min_t_v_t_v(a, b):
    return torch.minimum(a, b)
def h_min_t_v_n(a, b):
    a = get_gpu_value(a)
    b = get_s_gpu_tensor(b)
    return torch.minimum(a, b)
def h_min_n_t_v(a, b):
    a = get_s_gpu_tensor(a)
    b = get_gpu_value(b)
    return torch.minimum(a, b)

def h_where_n_n_n(b, y, n):
    return y if b else n
def h_where_n_v_v(b, y, n):
    return y if b else n
def h_where_n_t_n_t_n(b, y, n):
    return y if b else n
def h_where_n_t_v_t_v(b, y, n):
    return y if b else n
def h_where_n_n_t_n(b, y, n):
    ct = len(n)
    y = torch.broadcast_to(get_s_gpu_tensor(y), [ct])
    return y if b else n
def h_where_n_t_n_n(b, y, n):
    ct = len(y)
    n = torch.broadcast_to(get_s_gpu_tensor(n), [ct])
    y = get_gpu_value(y)
    n = get_gpu_value(n)
    return y if b else n
def h_where_n_v_t_v(b, y, n):
    ct = len(n)
    y = torch.broadcast_to(get_vm_gpu_tensor(y), (ct, len(y)))
    return y if b else n
def h_where_n_t_v_v(b, y, n):
    ct = len(y)
    n = torch.broadcast_to(n, (ct, len(n)))
    y = get_gpu_value(y)
    n = get_gpu_value(n)
    return y if b else n
def h_where_t_n_t_n_t_n(b, y, n):
    b = get_gpu_value(b)
    y = get_gpu_value(y)
    n = get_gpu_value(n)
    return torch.where(b, y, n)
def h_where_t_n_t_v_t_v(b, y, n):
    ct = len(y[0])
    b = torch.broadcast_to(b, (ct, len(b))).T
    b = get_gpu_value(b)
    y = get_gpu_value(y)
    n = get_gpu_value(n)
    return torch.where(b, y, n)
def h_where_t_n_t_v_v(b, y, n):
    ct = len(y[0])
    b = torch.broadcast_to(b, (ct, len(b))).T
    n = torch.broadcast_to(n, (len(y), ct))
    b = get_gpu_value(b)
    y = get_gpu_value(y)
    n = get_gpu_value(n)
    return torch.where(b, y, n)
def h_where_t_n_v_t_v(b, y, n):
    ct = len(n[0])
    b = torch.broadcast_to(b, (ct, len(b))).T
    y = torch.broadcast_to(y, (len(n), ct))
    b = get_gpu_value(b)
    y = get_gpu_value(y)
    n = get_gpu_value(n)
    return torch.where(b, y, n)
def h_where_t_n_v_v(b, y, n):
    ct = len(n)
    b = torch.broadcast_to(b, (ct, len(b))).T
    y = torch.broadcast_to(y, (len(b), ct))
    n = torch.broadcast_to(n, (len(b), ct))
    b = get_gpu_value(b)
    y = get_gpu_value(y)
    n = get_gpu_value(n)
    return torch.where(b, y, n)
def h_where_t_n_t_n_n(b, y, n):
    ct = len(y)
    n = torch.broadcast_to(get_s_gpu_tensor(n), [ct])
    b = get_gpu_value(b)
    y = get_gpu_value(y)
    n = get_gpu_value(n)
    return torch.where(b, y, n)
def h_where_t_n_n_t_n(b, y, n):
    ct = len(n)
    y = torch.broadcast_to(get_s_gpu_tensor(y), [ct])
    b = get_gpu_value(b)
    y = get_gpu_value(y)
    n = get_gpu_value(n)
    return torch.where(b, y, n)
def h_where_t_n_n_n(b, y, n):
    ct = len(b)
    y = torch.broadcast_to(get_s_gpu_tensor(y), [ct])
    n = torch.broadcast_to(get_s_gpu_tensor(n), [ct])
    b = get_gpu_value(b)
    y = get_gpu_value(y)
    n = get_gpu_value(n)
    return torch.where(b, y, n)
def h_where_t_n_t_m_t_m(b, y, n):
    ct = len(b)
    m1 = len(y[0])
    m2 = len(y[0][0])
    b = torch.broadcast_to(b, (m2, m1, ct)).T
    b = get_gpu_value(b)
    y = get_gpu_value(y)
    n = get_gpu_value(n)
    return torch.where(b, y, n)
def h_where_n_t_m_t_m(b, y, n):
    return y if b else n
def h_where_n_m_m(b, y, n):
    return y if b else n
def h_where_n_t_an_t_an(b, y, n):
    return y if b else n
def h_where_n_t_an_an(b, y, n):
    m1 = len(n)
    m2 = len(y[0])
    n = torch.broadcast_to(n, (m2, m1)).T
    return y if b else n
def h_where_n_an_t_an(b, y, n):
    m1 = len(y)
    m2 = len(n[0])
    y = torch.broadcast_to(y, (m2, m1)).T
    return y if b else n
def h_where_t_n_t_an_t_an(b, y, n):
    b = get_gpu_value(b)
    y = get_gpu_value(y)
    n = get_gpu_value(n)
    ct = len(b)
    m = len(y)
    b = torch.broadcast_to(b, (m, ct))
    return torch.where(b, y, n)
def h_where_t_n_t_av_t_av(b, y, n):
    ct = len(b)
    m1 = len(y)
    m2 = len(y[0][0])
    b = torch.broadcast_to(b, (m1, m2, ct)).transpose(2, 1)
    return torch.where(b, y, n)
def h_where_n_t_av_t_av(b, y, n):
    return y if b else n
def h_where_v_v_v(b, y, n):
    return torch.where(b, y, n)
def h_where_t_v_v_t_v(b, y, n):
    b = get_gpu_value(b)
    n = get_gpu_value(n)
    m = len(b)
    y = torch.broadcast_to(get_vm_gpu_tensor(y), (m, len(y)))
    y = get_gpu_value(y)
    return torch.where(b, y, n)

def h_step_n_n(y, x):
    x = get_s_gpu_tensor(x)
    y = get_s_gpu_tensor(y)
    x, y = change_to_same_f64(x, y)
    return torch.heaviside(x - y, gpu_one_tensor)
def h_step_v_n(y, x):
    x = get_s_gpu_tensor(x)
    y = get_vm_gpu_tensor(y)
    x, y = change_to_same_f64(x, y)
    return torch.heaviside(x - y, gpu_one_tensor)
def h_step_n_v(y, x):
    x = get_vm_gpu_tensor(x)
    y = get_s_gpu_tensor(y)
    return torch.heaviside(x - y, gpu_one_tensor)
def h_step_v_v(y, x):
    x = get_vm_gpu_tensor(x)
    y = get_vm_gpu_tensor(y)
    x, y = change_to_same_f64(x, y)
    return torch.heaviside(x - y, gpu_one_tensor)
def h_step_t_v_v(y, x):
    x = torch.broadcast_to(x, (len(y), len(x)))
    x = get_gpu_value(x)
    y = get_gpu_value(y)
    x, y = change_to_same_f64(x, y)
    return torch.heaviside(x - y, gpu_one_tensor)
def h_step_v_t_v(y, x):
    y = torch.broadcast_to(y, (len(x), len(y)))
    x = get_gpu_value(x)
    y = get_gpu_value(y)
    x, y = change_to_same_f64(x, y)
    return torch.heaviside(x - y, gpu_one_tensor)
def h_step_t_v_t_v(y, x):
    x = get_gpu_value(x)
    y = get_gpu_value(y)
    x, y = change_to_same_f64(x, y)
    return torch.heaviside(x - y, gpu_one_tensor)
def h_step_n_t_v(y, x):
    y = torch.broadcast_to(get_s_gpu_tensor(y), (len(x), len(x[0])))
    x = get_gpu_value(x)
    y = get_gpu_value(y)
    x, y = change_to_same_f64(x, y)
    return torch.heaviside(x - y, gpu_one_tensor)
def h_step_n_t_n(y, x):
    y = torch.broadcast_to(get_s_gpu_tensor(y), [len(x)])
    x = get_gpu_value(x)
    y = get_gpu_value(y)
    x, y = change_to_same_f64(x, y)
    return torch.heaviside(x - y, gpu_one_tensor)
def h_step_t_n_n(y, x):
    x = torch.broadcast_to(get_s_gpu_tensor(x), [len(y)])
    x = get_gpu_value(x)
    y = get_gpu_value(y)
    x, y = change_to_same_f64(x, y)
    return torch.heaviside(x - y, gpu_one_tensor)
def h_step_t_n_t_n(y, x):
    x = get_gpu_value(x)
    y = get_gpu_value(y)
    x, y = change_to_same_f64(x, y)
    return torch.heaviside(x - y, gpu_one_tensor)

def h_abs_n(v):
    v = get_s_gpu_tensor(v)
    return torch.abs(v)
def h_abs_v(v):
    return torch.abs(v)
def h_abs_t_n(v):
    return torch.abs(v)
def h_abs_t_v(v):
    return torch.abs(v)

def h_any_n(v):
    v = get_s_gpu_tensor(v)
    return torch.any(v)
def h_any_v(v):
    return torch.any(v)
def h_any_t_n(v):
    ct = len(v)
    v = torch.broadcast_to(v, (1, ct))
    return torch.any(v, 0)
def h_any_t_v(v):
    return torch.any(v, 1)

def h_all_n(v):
    v = get_s_gpu_tensor(v)
    return torch.all(v)
def h_all_v(v):
    return torch.all(v)
def h_all_t_n(v):
    ct = len(v)
    v = torch.broadcast_to(v, (1, ct))
    return torch.all(v, 0)
def h_all_t_v(v):
    return torch.all(v, 1)

def array_init_an(arr):
    return torch.asarray(arr, device=device)
def array_init_an2(arr):
    return torch.stack(arr)
def array_init_an3(arr):
    return torch.stack(arr)
def array_init_an4(arr):
    return torch.stack(arr)
def array_init_t_an(arr):
    return torch.stack(arr)
def array_init_t_an2(arr):
    return torch.stack(arr)
def array_init_t_an3(arr):
    return torch.stack(arr)
def array_init_t_an4(arr):
    return torch.stack(arr)
def array_set_an_n(arr, ix, v):
    arr[ix] = v
    return v
def array_get_an_n(arr, ix):
    return arr[ix]
def array_set_t_an_n(arr, ix, v):
    arr[ix] = v
    return v
def array_get_t_an_n(arr, ix):
    return arr[ix]
def array_set_an2_n(arr, ix, v):
    arr[ix] = v
    return v
def array_get_an2_n(arr, ix):
    return arr[ix]
def array_set_an3_n(arr, ix, v):
    arr[ix] = v
    return v
def array_get_an3_n(arr, ix):
    return arr[ix]
def array_set_an4_n(arr, ix, v):
    arr[ix] = v
    return v
def array_get_an4_n(arr, ix):
    return arr[ix]
def array_set_t_an2_n(arr, ix, v):
    arr[ix] = v
    return v
def array_get_t_an2_n(arr, ix):
    r = arr[ix]
    return r
def array_set_t_an3_n(arr, ix, v):
    arr[ix] = v
    return v
def array_get_t_an3_n(arr, ix):
    r = arr[ix]
    return r
def array_set_t_an4_n(arr, ix, v):
    arr[ix] = v
    return v
def array_get_t_an4_n(arr, ix):
    r = arr[ix]
    return r
def array_set_an_t_n(arr, ix, v):
    arr[ix.long()] = v
    return v
def array_get_an_t_n(arr, ix):
    r = arr[ix.long()]
    return r
def array_set_an2_t_n(arr, ix, v):
    arr[ix.long()] = v
    return v
def array_get_an2_t_n(arr, ix):
    r = arr[ix.long()]
    return r
def array_set_an3_t_n(arr, ix, v):
    arr[ix.long()] = v
    return v
def array_get_an3_t_n(arr, ix):
    r = arr[ix.long()]
    return r
def array_set_an4_t_n(arr, ix, v):
    arr[ix.long()] = v
    return v
def array_get_an4_t_n(arr, ix):
    r = arr[ix.long()]
    return r
def array_set_t_an_t_n(arr, ix, v):
    arr = get_gpu_value(arr)
    ix = get_gpu_value(ix)
    v = get_gpu_value(v)
    arr, v = change_to_same_f64(arr, v)
    n = len(ix)
    nix = poolGetN(n)
    arr[ix.long(), nix] = v
    return v
def array_get_t_an_t_n(arr, ix):
    arr = get_gpu_value(arr)
    ix = get_gpu_value(ix)
    n = len(ix)
    nix = poolGetN(n)
    r = arr[ix.long(), nix]
    return r
def array_set_t_an2_t_n(arr, ix, v):
    arr = get_gpu_value(arr)
    ix = get_gpu_value(ix)
    v = get_gpu_value(v)
    arr, v = change_to_same_f64(arr, v)
    n = len(ix)
    nix = poolGetN(n)
    arr[ix.long(), nix] = v
    return v
def array_get_t_an2_t_n(arr, ix):
    arr = get_gpu_value(arr)
    ix = get_gpu_value(ix)
    n = len(ix)
    nix = poolGetN(n)
    r = arr[ix.long(), nix]
    return r
def array_set_t_an3_t_n(arr, ix, v):
    arr = get_gpu_value(arr)
    ix = get_gpu_value(ix)
    v = get_gpu_value(v)
    arr, v = change_to_same_f64(arr, v)
    n = len(ix)
    nix = poolGetN(n)
    arr[ix.long(), nix] = v
    return v
def array_get_t_an3_t_n(arr, ix):
    arr = get_gpu_value(arr)
    ix = get_gpu_value(ix)
    n = len(ix)
    nix = poolGetN(n)
    r = arr[ix.long(), nix]
    return r
def array_set_t_an4_t_n(arr, ix, v):
    arr = get_gpu_value(arr)
    ix = get_gpu_value(ix)
    v = get_gpu_value(v)
    arr, v = change_to_same_f64(arr, v)
    n = len(ix)
    nix = poolGetN(n)
    arr[ix.long(), nix] = v
    return v
def array_get_t_an4_t_n(arr, ix):
    arr = get_gpu_value(arr)
    ix = get_gpu_value(ix)
    n = len(ix)
    nix = poolGetN(n)
    r = arr[ix.long(), nix]
    return r
def array_set_n2_n(arr, ix, v):
    arr[ix] = v
    return v
def array_get_n2_n(arr, ix):
    r = arr[ix]
    return r
def array_set_n3_n(arr, ix, v):
    arr[ix] = v
    return v
def array_get_n3_n(arr, ix):
    r = arr[ix]
    return r
def array_set_n4_n(arr, ix, v):
    arr[ix] = v
    return v
def array_get_n4_n(arr, ix):
    r = arr[ix]
    return r
def array_set_n2x2_n(m, ix, val):
    m[ix][0] = val[0]
    m[ix][1] = val[1]
def array_get_n2x2_n(m, ix):
    arr = m[ix]
    return arr
def array_set_n3x3_n(m, ix, val):
    m[ix][0] = val[0]
    m[ix][1] = val[1]
    m[ix][2] = val[2]
def array_get_n3x3_n(m, ix):
    arr = m[ix]
    return arr
def array_set_n4x4_n(m, ix, val):
    m[ix][0] = val[0]
    m[ix][1] = val[1]
    m[ix][2] = val[2]
    m[ix][3] = val[3]
def array_get_n4x4_n(m, ix):
    arr = m[ix]
    return arr
def array_set_t_n2_n(m, ix, val):
    m[..., ix] = val
    return val
def array_get_t_n2_n(m, ix):
    v = m[..., ix]
    return v
def array_set_t_n3_n(m, ix, val):
    m[..., ix] = val
    return val
def array_get_t_n3_n(m, ix):
    v = m[..., ix]
    return v
def array_set_t_n4_n(m, ix, val):
    m[..., ix] = val
    return val
def array_get_t_n4_n(m, ix):
    v = m[..., ix]
    return v
def array_set_t_n2x2_n(m, ix, val):
    m.swapaxes(1,2)[..., ix][..., 0] = val[..., 0]
    m.swapaxes(1,2)[..., ix][..., 1] = val[..., 1]
    return val
def array_get_t_n2x2_n(m, ix):
    v = m.swapaxes(1,2)[..., ix]
    return v
def array_set_t_n3x3_n(m, ix, val):
    m.swapaxes(1,2)[..., ix][..., 0] = val[..., 0]
    m.swapaxes(1,2)[..., ix][..., 1] = val[..., 1]
    m.swapaxes(1,2)[..., ix][..., 2] = val[..., 2]
    return val
def array_get_t_n3x3_n(m, ix):
    v = m.swapaxes(1,2)[..., ix]
    return v
def array_set_t_n4x4_n(m, ix, val):
    m.swapaxes(1,2)[..., ix][..., 0]  = val[..., 0]
    m.swapaxes(1,2)[..., ix][..., 1]  = val[..., 1]
    m.swapaxes(1,2)[..., ix][..., 2]  = val[..., 2]
    m.swapaxes(1,2)[..., ix][..., 3]  = val[..., 3]
    return val
def array_get_t_n4x4_n(m, ix):
    v = m.swapaxes(1,2)[..., ix]
    return v
def array_set_t_n2_n(m, ix, val):
    m[..., ix] = val
    return val
def array_get_t_n2_n(m, ix):
    v = m[..., ix]
    return v
def array_set_t_n3_n(m, ix, val):
    m[..., ix] = val
    return val
def array_get_t_n3_n(m, ix):
    v = m[..., ix]
    return v
def array_set_t_n4_n(m, ix, val):
    m[..., ix] = val
    return val
def array_get_t_n4_n(m, ix):
    v = m[..., ix]
    return v

def array_set_and_broadcast_n3_n(vec, ix, v):
    m = len(v)
    vec = torch.tile(vec, (m, 1))
    vec[..., ix] = v
def array_set_and_broadcast_n3x3_n(mat, ix, v):
    m = len(v)
    mat = torch.tile(mat, (m, 1))
    mat.swapaxes(1,2)[..., ix][..., 0] = val[..., 0]
    mat.swapaxes(1,2)[..., ix][..., 1] = val[..., 1]
    mat.swapaxes(1,2)[..., ix][..., 2] = val[..., 2]
def array_set_and_broadcast_an_n(arr, ix, v):
    m = len(v)
    arr = torch.tile(arr, (m, 1)).swapaxes(0, 1)
    arr[ix] = v
    return v, arr
def array_set_and_broadcast_an2_n(arr, ix, v):
    m = len(v)
    arr = torch.tile(arr, (m, 1, 1)).swapaxes(0, 1)
    arr[ix] = v
    return v, arr
def array_set_and_broadcast_an3_n(arr, ix, v):
    m = len(v)
    arr = torch.tile(arr, (m, 1, 1)).swapaxes(0, 1)
    arr[ix] = v
    return v, arr
def array_set_and_broadcast_an4_n(arr, ix, v):
    m = len(v)
    arr = torch.tile(arr, (m, 1, 1)).swapaxes(0, 1)
    arr[ix] = v
    return v, arr

def array_broadcast_an(writable, arr):
    global vec_broadcast_count
    if writable:
        arr = torch.tile(arr, (vec_broadcast_count, 1)).swapaxes(0, 1)
    else:
        arr = torch.broadcast_to(arr, (vec_broadcast_count, len(arr))).swapaxes(0, 1)
    return arr
def array_broadcast_an2(writable, arr):
    global vec_broadcast_count
    if writable:
        arr = torch.tile(arr, (vec_broadcast_count, 1, 1)).swapaxes(0, 1)
    else:
        arr = torch.broadcast_to(arr, (vec_broadcast_count, len(arr), 2)).swapaxes(0, 1)
    return arr
def array_broadcast_an3(writable, arr):
    global vec_broadcast_count
    if writable:
        arr = torch.tile(arr, (vec_broadcast_count, 1, 1)).swapaxes(0, 1)
    else:
        arr = torch.broadcast_to(arr, (vec_broadcast_count, len(arr), 3)).swapaxes(0, 1)
    return arr
def array_broadcast_an4(writable, arr):
    global vec_broadcast_count
    if writable:
        arr = torch.tile(arr, (vec_broadcast_count, 1, 1)).swapaxes(0, 1)
    else:
        arr = torch.broadcast_to(arr, (vec_broadcast_count, len(arr), 4)).swapaxes(0, 1)
    return arr

def swizzle(v, m, dim, dim2 = None):
    if maybe_vec_mat_array(v):
        if dim == 2 and dim2 is None and m == "xy":
            nv = torch.clone(v)
            return nv
        elif dim == 3 and dim2 is None and m == "xyz":
            nv = torch.clone(v)
            return nv
        elif dim == 4 and dim2 is None and m == "xyzw":
            nv = torch.clone(v)
            return nv
        elif m == "x":
            return v[..., 0]
        elif m == "y":
            return v[..., 1]
        elif m == "z":
            return v[..., 2]
        elif m == "w":
            return v[..., 3]
        else:
            nv = list()
            for c in m:
                if c == "x":
                    nv.append(v[..., 0])
                elif c == "y":
                    nv.append(v[..., 1])
                elif c == "z":
                    nv.append(v[..., 2])
                elif c == "w":
                    nv.append(v[..., 3])
            return torch.column_stack(nv)
    else:
        if dim == 2 and dim2 is None and m == "xy":
            return v
        elif dim == 3 and dim2 is None and m == "xyz":
            return v
        elif dim == 4 and dim2 is None and m == "xyzw":
            return v
        elif m == "x":
            return v[0]
        elif m == "y":
            return v[1]
        elif m == "z":
            return v[2]
        elif m == "w":
            return v[3]
        else:
            nv = list()
            for c in m:
                if c == "x":
                    nv.append(v[0])
                elif c == "y":
                    nv.append(v[1])
                elif c == "z":
                    nv.append(v[2])
                elif c == "w":
                    nv.append(v[3])
            return get_vm_gpu_tensor(nv)

def swizzle_set(v, m, val, dim, dim2 = None):
    if maybe_vec_mat_array(v):
        if dim == 2 and dim2 is None and m == "xy":
            torch.copyto(v, val)
        elif dim == 3 and dim2 is None and m == "xyz":
            torch.copyto(v, val)
        elif dim == 4 and dim2 is None and m == "xyzw":
            torch.copyto(v, val)
        elif m == "x":
            v[..., 0] = val
        elif m == "y":
            v[..., 1] = val
        elif m == "z":
            v[..., 2] = val
        elif m == "w":
            v[..., 3] = val
        else:
            ns = len(m)
            ix = 0
            for c in m:
                if c == "x":
                    v[..., 0] = val[..., ix]
                elif c == "y":
                    v[..., 1] = val[..., ix]
                elif c == "z":
                    v[..., 2] = val[..., ix]
                elif c == "w":
                    v[..., 3] = val[..., ix]
                ix = ix + 1
    else:
        if dim == 2 and dim2 is None and m == "xy":
            torch.copyto(v, val)
        elif dim == 3 and dim2 is None and m == "xyz":
            torch.copyto(v, val)
        elif dim == 4 and dim2 is None and m == "xyzw":
            torch.copyto(v, val)
        elif m == "x":
            v[0] = val
        elif m == "y":
            v[1] = val
        elif m == "z":
            v[2] = val
        elif m == "w":
            v[3] = val
        else:
            ns = len(m)
            ix = 0
            for c in m:
                if c == "x":
                    v[0] = val[ix]
                elif c == "y":
                    v[1] = val[ix]
                elif c == "z":
                    v[2] = val[ix]
                elif c == "w":
                    v[3] = val[ix]
                ix = ix + 1

class SwizzleObject:
    def __init__(self, ndarr, dim, dim2 = None):
        self.dim = dim
        self.dim2 = dim2
        self.arr = ndarr
    def __getattr__(self, name):
        if name == "dim" or name == "dim2" or name == "arr":
            return object.__getattribute__(self, name)
        if self.dim == 2 and self.dim2 is None:
            return swizzle(self.arr, name, 2)
        elif self.dim == 3 and self.dim2 is None:
            return swizzle(self.arr, name, 3)
        elif self.dim == 4 and self.dim2 is None:
            return swizzle(self.arr, name, 4)
        else:
            return object.__getattribute__(self, name)
    def __setattr__(self, name, val):
        if name == "dim" or name == "dim2" or name == "arr":
            object.__setattr__(self, name, val)
            return
        if self.dim == 2 and self.dim2 is None:
            swizzle_set(self.arr, name, val, 2)
        elif self.dim == 3 and self.dim2 is None:
            swizzle_set(self.arr, name, val, 3)
        elif self.dim == 4 and self.dim2 is None:
            swizzle_set(self.arr, name, val, 4)
        else:
            object.__setattr__(self, name, val)


def h_inc_i(v):
    return v + 1
def h_dec_i(v):
    return v - 1
def h_inc_vi(v):
    return v + 1
def h_dec_vi(v):
    return v - 1
def h_inc_t_i(v):
    return v + 1
def h_dec_t_i(v):
    return v - 1
def h_inc_t_vi(v):
    return v + 1
def h_dec_t_vi(v):
    return v - 1
def h_inc_f(v):
    return v + 1
def h_dec_f(v):
    return v - 1
def h_inc_t_f(v):
    return v + 1
def h_dec_t_f(v):
    return v + 1

def h_add_f(v):
    return v
def h_sub_f(v):
    return -v
def h_not_n(v):
    return not v
def h_bitnot_i(v):
    return ~v
def h_bitnot_u(v):
    return (~v) + (1<<32)
def h_bitnot_vi(v):
    return ~v
def h_bitnot_vi(v):
    return ~v
def h_bitnot_vi(v):
    return ~v

def h_add_t_f(v):
    return +v
def h_sub_t_f(v):
    return -v
def h_add_t_vf(v):
    return +v
def h_sub_t_vf(v):
    return -v
def h_add_vf(v):
    return v
def h_sub_vf(v):
    return -v


def h_not_v(v):
    return not v
def h_not_t_n(v):
    return torch.bitwise_not(v.bool())

def h_add_f_f(a, b):
    return a + b
def h_sub_f_f(a, b):
    return a - b
def h_mul_f_f(a, b):
    return a * b
def h_div_f_f(a, b):
    if b == 0:
        return sys.float_info.max
    return a / b
def h_mod_i_i(a, b):
    return a % b

def h_add_vf_f(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return torch.add(a, b)
def h_sub_vf_f(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return torch.sub(a, b)
def h_mul_vf_f(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return torch.mul(a, b)
def h_div_vf_f(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return torch.div(a, b)
def h_mod_vi_i(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return torch.remainder(a, b)

def h_add_f_vf(a, b):
    a = get_s_gpu_tensor(a)
    b = get_vm_gpu_tensor(b)
    return a + b
def h_sub_f_vf(a, b):
    a = get_s_gpu_tensor(a)
    b = get_vm_gpu_tensor(b)
    return a - b
def h_mul_f_vf(a, b):
    a = get_s_gpu_tensor(a)
    b = get_vm_gpu_tensor(b)
    return a * b
def h_div_f_vf(a, b):
    a = get_s_gpu_tensor(a)
    b = get_vm_gpu_tensor(b)
    return a / b
def h_mod_i_vi(a, b):
    a = get_s_gpu_tensor(a)
    b = get_vm_gpu_tensor(b)
    return a % b

def h_add_vf_vf(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_vm_gpu_tensor(b)
    return torch.add(a, b)
def h_sub_vf_vf(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_vm_gpu_tensor(b)
    return torch.sub(a, b)
def h_mul_vf_vf(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_vm_gpu_tensor(b)
    return torch.mul(a, b)
def h_div_vf_vf(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_vm_gpu_tensor(b)
    return torch.div(a, b)
def h_mod_vi_vi(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_vm_gpu_tensor(b)
    return torch.remainder(a, b)

def h_and_n_n(a, b):
    return a and b
def h_or_n_n(a, b):
    return a or b

def h_and_v_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return a and b
def h_or_v_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return a or b

def h_and_t_n_n(a, b):
    b = torch.broadcast_to(get_s_gpu_tensor(b), [len(a)])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = torch.logical_and(a, b)
    return r
def h_and_n_t_n(a, b):
    a = torch.broadcast_to(a, [len(b)])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = torch.logical_and(a, b)
    return r
def h_and_t_n_t_n(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = torch.logical_and(a, b)
    return r
def h_or_t_n_n(a, b):
    b = torch.broadcast_to(get_s_gpu_tensor(b), [len(a)])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = torch.logical_or(a, b)
    return r
def h_or_n_t_n(a, b):
    a = torch.broadcast_to(get_s_gpu_tensor(a), [len(b)])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = torch.logical_or(a, b)
    return r
def h_or_t_n_t_n(a, b):
    r = torch.logical_or(a, b)
    return r

def h_add_t_f_t_f(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.add(a, b)
def h_add_t_vf_t_vf(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.add(a, b)
def h_add_f_t_f(a, b):
    return torch.add(a, b)
def h_add_t_f_f(a, b):
    return torch.add(a, b)
def h_add_t_i_i(a, b):
    b = torch.broadcast_to(get_s_gpu_tensor(b), [len(a)])
    r = a + b
    return r
def h_add_t_u_i(a, b):
    b = torch.broadcast_to(get_s_gpu_tensor(b), [len(a)])
    r = a + b
    return r
def h_add_t_u_u(a, b):
    b = torch.broadcast_to(get_s_gpu_tensor(b), [len(a)])
    r = a + b
    return r
def h_add_t_u_t_u(a, b):
    r = a + b
    return r
def h_add_f_t_vf(a, b):
    return a + b
def h_add_t_vf_f(a, b):
    return a + b
def h_add_t_f_vf(a, b):
    m = len(a)
    n = len(b)
    b = torch.broadcast_to(get_vm_gpu_tensor(b), (m, n))
    a = torch.broadcast_to(a, (n, m)).T
    a = get_gpu_value(a)
    return a + b
def h_add_vf_t_f(a, b):
    m = len(b)
    n = len(a)
    a = torch.broadcast_to(get_vm_gpu_tensor(a), (m, n))
    b = torch.broadcast_to(b, (n, m)).T
    b = get_gpu_value(b)
    return torch.add(a, b)
def h_add_t_vf_t_f(a, b):
    m = len(b)
    n = len(a[0])
    b = torch.broadcast_to(b, (n, m)).T
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return a + b
def h_add_t_f_t_vf(a, b):
    m = len(a)
    n = len(b[0])
    a = torch.broadcast_to(a, (n, m)).T
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return a + b
def h_add_vf_t_vf(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_gpu_value(b)
    return torch.add(a, b)
def h_add_t_vf_vf(a, b):
    a = get_gpu_value(a)
    b = get_vm_gpu_tensor(b)
    return torch.add(a, b)
def h_add_t_vu_t_vu(a, b):
    r = a + b
    r = torch.bitwise_and(r, 0xffffffff)
    return r
def h_add_vu_vu(a, b):
    r = a + b
    r = torch.bitwise_and(r, 0xffffffff)
    return r
def h_add_i_i(a, b):
    return a + b
def h_add_i_t_i(a, b):
    return a + b

def h_sub_i_i(a, b):
    return a - b
def h_sub_i_t_i(a, b):
    return a - b
def h_sub_vi_vi(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_gpu_value(b)
    return a - b
def h_sub_vi_t_vi(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return a - b
def h_sub_t_f_t_f(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.sub(a, b)
def h_sub_t_vf_t_vf(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.sub(a, b)
def h_sub_f_t_f(a, b):
    return torch.sub(a, b)
def h_sub_t_f_f(a, b):
    return torch.sub(a, b)
def h_sub_f_t_vf(a, b):
    return a - b
def h_sub_t_vf_f(a, b):
    return a - b
def h_sub_t_f_vf(a, b):
    m = len(a)
    n = len(b)
    a = torch.broadcast_to(a, (n, m)).T
    return a - b
def h_sub_vf_t_f(a, b):
    m = len(b)
    n = len(a)
    b = torch.broadcast_to(b, (n, m)).T
    return a - b
def h_sub_vf_t_vf(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_gpu_value(b)
    return torch.sub(a, b)
def h_sub_t_vf_vf(a, b):
    a = get_gpu_value(a)
    b = get_vm_gpu_tensor(b)
    return torch.sub(a, b)
def h_sub_t_vf_t_f(a, b):
    m = len(b)
    n = len(a[0])
    b = torch.broadcast_to(b, (n, m)).T
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return a - b
def h_sub_t_f_t_vf(a, b):
    m = len(a)
    n = len(b[0])
    a = torch.broadcast_to(a, (n, m)).T
    return a - b
def h_sub_mf_mf(a, b):
    return a - b
def h_sub_t_mf_mf(a, b):
    return a - b
def h_sub_i_f(a, b):
    return a - b

def h_mul_f_mf(a, b):
    a = get_s_gpu_tensor(a)
    b = get_vm_gpu_tensor(b)
    return a * b
def h_mul_mf_f(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return a * b
def h_mul_mf_t_mf(a, b):
    a = get_vm_gpu_tensor(a)
    b = get_gpu_value(b)
    return a * b
def h_mul_i_f(a, b):
    a = get_s_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return a * b
def h_mul_i_i(a, b):
    a = get_s_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return a * b
def h_mul_u_u(a, b):
    a = get_s_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return a * b
def h_mul_u_t_u(a, b):
    a = get_s_gpu_tensor(a)
    b = get_gpu_value(b)
    return a * b
def h_mul_t_f_i(a, b):
    a = get_gpu_value(a)
    b = get_s_gpu_tensor(b)
    return a * b
def h_mul_t_f_t_f(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.mul(a, b)
def h_mul_t_vf_t_vf(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.mul(a, b)
def h_mul_t_vf_t_f(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.mul(a.T, b).T
def h_mul_t_f_t_vf(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.mul(a, b.T).T
def h_mul_f_t_f(a, b):
    a = get_s_gpu_tensor(a)
    b = get_gpu_value(b)
    return torch.mul(a, b)
def h_mul_t_f_f(a, b):
    a = get_gpu_value(a)
    b = get_s_gpu_tensor(b)
    return torch.mul(a, b)
def h_mul_f_t_i(a, b):
    a = get_s_gpu_tensor(a)
    b = get_gpu_value(b)
    return torch.mul(a, b)
def h_mul_f_t_vf(a, b):
    a = get_s_gpu_tensor(a)
    b = get_gpu_value(b)
    return a * b
def h_mul_t_vf_f(a, b):
    a = get_gpu_value(a)
    b = get_s_gpu_tensor(b)
    return a * b
def h_mul_t_f_vf(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    a = a.reshape(len(a), 1)
    return torch.mul(a, b)
def h_mul_vf_t_f(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    b = b.reshape(len(b), 1)
    return torch.mul(a, b)
def h_mul_vf_t_vf(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.mul(a, b)
def h_mul_t_vf_vf(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.mul(a, b)
def h_mul_t_vu_vu(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = torch.mul(a, b)
    r = torch.bitwise_and(r, 0xffffffff)
    return r
def h_mul_t_vu_t_vu(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = torch.mul(a, b)
    r = torch.bitwise_and(r, 0xffffffff)
    return r
def h_mul_vu_vu(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = torch.mul(a, b)
    r = torch.bitwise_and(r, 0xffffffff)
    return r
def h_mul_vi_vi(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = torch.mul(a, b)
    r = torch.bitwise_and(r, 0xffffffff)
    return int(r)
def h_mul_vd_vd(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = torch.mul(a, b)
    return r
def h_mul_vb_vb(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = torch.mul(a, b)
    return r
def h_mul_t_i_f(a, b):
    a = get_gpu_value(a)
    b = get_s_gpu_tensor(b)
    r = a * b
    return r
def h_mul_t_i_t_f(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = a * b
    return r
def h_mul_t_f_t_i(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = a * b
    return r
def h_mul_t_u_i(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = a * b
    return r
def h_mul_t_u_t_u(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = a * b
    return r
def h_mul_t_u_t_vu(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = a * b
    return r
def h_mul_t_mf_t_f(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = a * b
    return r
def h_mul_t_mf_t_f(a, b):
    ct = len(a)
    m = len(a[0])
    n = len(a[0][0])
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    b = torch.swapaxes(torch.broadcast_to(b, (n, m, ct)), 0, 2)
    r = a * b
    return r

def h_div_i_i(a, b):
    a = get_s_gpu_tensor(a)
    b = get_s_gpu_tensor(b)
    return a // b
def h_div_t_i_i(a, b):
    a = get_gpu_value(a)
    b = get_s_gpu_tensor(b)
    return a // b
def h_div_t_f_t_f(a, b):
    b = b + sys.float_info.epsilon
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.div(a, b)
def h_div_t_vf_t_vf(a, b):
    b = b + sys.float_info.epsilon
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.div(a, b)
def h_div_f_t_f(a, b):
    b = b + sys.float_info.epsilon
    a = get_s_gpu_tensor(a)
    b = get_gpu_value(b)
    return torch.div(a, b)
def h_div_t_f_f(a, b):
    b = b + sys.float_info.epsilon
    a = get_gpu_value(a)
    b = get_s_gpu_tensor(b)
    return torch.div(a, b)
def h_div_f_t_vf(a, b):
    b = b + sys.float_info.epsilon
    a = get_s_gpu_tensor(a)
    b = get_gpu_value(b)
    return a / b
def h_div_t_vf_f(a, b):
    b = b + sys.float_info.epsilon
    a = get_gpu_value(a)
    b = get_s_gpu_tensor(b)
    return a / b
def h_div_t_f_vf(a, b):
    b = b + sys.float_info.epsilon
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    a = a.reshape(len(a), 1)
    return torch.div(a, b)
def h_div_vf_t_f(a, b):
    b = b + sys.float_info.epsilon
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    b = b.reshape(len(b), 1)
    return torch.div(a, b)
def h_div_vf_t_vf(a, b):
    b = b + sys.float_info.epsilon
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.div(a, b)
def h_div_t_vf_vf(a, b):
    b = b + sys.float_info.epsilon
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.div(a, b)
def h_div_t_vf_t_f(a, b):
    b = b + sys.float_info.epsilon
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = torch.div(a.T, b).T
    return r
def h_div_t_mf_t_f(a, b):
    b = b + sys.float_info.epsilon
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    r = torch.div(a.T, b).T
    return r

def h_mod_t_i_t_i(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.remainder(a, b)
def h_mod_t_vi_t_vi(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.remainder(a, b)
def h_mod_i_t_i(a, b):
    return torch.remainder(a, b)
def h_mod_t_i_i(a, b):
    return torch.remainder(a, b)
def h_mod_i_t_vi(a, b):
    return a % b
def h_mod_t_vi_i(a, b):
    return a % b
def h_mod_t_i_vi(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    a = a.reshape(len(a), 1)
    return torch.remainder(a, b)
def h_mod_vi_t_i(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    b = b.reshape(len(b), 1)
    return torch.remainder(a, b)
def h_mod_vi_t_vi(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.remainder(a, b)
def h_mod_t_vi_vi(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.remainder(a, b)

def h_bitand_i_i(a, b):
    return a & b
def h_bitand_t_i_i(a, b):
    return a & b
def h_bitand_t_vi_i(a, b):
    return a & b
def h_bitand_t_vi_vi(a, b):
    return a & b
def h_bitand_t_u_u(a, b):
    return a & b
def h_bitand_t_vu_vu(a, b):
    return a & b
def h_bitor_i_i(a, b):
    return a | b
def h_bitxor_i_i(a, b):
    return a ^ b
def h_bitxor_t_u_t_u(a, b):
    r = a ^ b
    r = torch.bitwise_and(r, 0xffffffff)
    return r
def h_bitxor_t_vu_t_vu(a, b):
    r = a ^ b
    r = torch.bitwise_and(r, 0xffffffff)
    return r
def h_bitxor_vu_vu(a, b):
    r = a ^ b
    r = torch.bitwise_and(r, 0xffffffff)
    return r

def h_lshift_i_i(a, b):
    return a << b
def h_rshift_i_i(a, b):
    return a >> b
def h_lshift_t_u_i(a, b):
    r = a << b
    r = torch.bitwise_and(r, 0xffffffff)
    return r
def h_rshift_t_u_i(a, b):
    r = a >> b
    r = torch.bitwise_and(r, 0xffffffff)
    return r
def h_rshift_t_vu_i(a, b):
    r = a >> b
    r = torch.bitwise_and(r, 0xffffffff)
    return r
def h_rshift_t_vu_vu(a, b):
    r = a >> b
    r = torch.bitwise_and(r, 0xffffffff)
    return r
def h_rshift_vu_i(a, b):
    r = a >> b
    r = torch.bitwise_and(r, 0xffffffff)
    return r

def h_less_than_n_n(a, b):
    return a < b
def h_greater_than_n_n(a, b):
    return a > b
def h_less_equal_than_n_n(a, b):
    return a <= b
def h_greater_equal_than_n_n(a, b):
    return a >= b

def h_less_than_v_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return a < b
def h_greater_than_v_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return a > b
def h_less_equal_than_v_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return a <= b
def h_greater_equal_than_v_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return a >= b
def h_less_than_t_n_t_n(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return a < b
def h_greater_than_t_n_t_n(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return a > b
def h_less_equal_than_t_n_t_n(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return a <= b
def h_greater_equal_than_t_n_t_n(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return a >= b
def h_less_than_t_n_n(a, b):
    return a < b
def h_greater_than_t_n_n(a, b):
    return a > b
def h_less_equal_than_t_n_n(a, b):
    return a <= b
def h_greater_equal_than_t_n_n(a, b):
    return a >= b
def h_less_than_n_t_n(a, b):
    return a < b
def h_greater_than_n_t_n(a, b):
    return a > b
def h_less_equal_than_n_t_n(a, b):
    return a <= b
def h_greater_equal_than_n_t_n(a, b):
    return a >= b

def h_equal_n_n(a, b):
    return a == b
def h_not_equal_n_n(a, b):
    return a != b
def h_equal_v_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.all(a == b)
def h_not_equal_v_v(a, b):
    a = get_gpu_value(a)
    b = get_gpu_value(b)
    return torch.any(a != b)

def h_equal_t_n_n(a, b):
    return a == b
def h_not_equal_t_n_n(a, b):
    return a != b
def h_equal_t_v_v(a, b):
    return a == b
def h_not_equal_t_v_v(a, b):
    return a != b
def h_equal_n_t_n(a, b):
    return a == b
def h_not_equal_n_t_n(a, b):
    return a != b
def h_equal_t_n_t_n(a, b):
    return a == b
def h_not_equal_t_n_t_n(a, b):
    return a != b

def h_broadcast_f(writable, v):
    global vec_broadcast_count
    return torch.broadcast_to(get_s_gpu_tensor(v), [vec_broadcast_count])
def h_broadcast_b(writable, v):
    global vec_broadcast_count
    return torch.broadcast_to(get_s_gpu_tensor(v), [vec_broadcast_count])
def h_broadcast_i(writable, v):
    global vec_broadcast_count
    return torch.broadcast_to(get_s_gpu_tensor(v), [vec_broadcast_count])
def h_broadcast_f2(writable, v):
    global vec_broadcast_count
    if writable:
        return torch.tile(get_vm_gpu_tensor(v), (vec_broadcast_count, 1))
    else:
        return torch.broadcast_to(get_vm_gpu_tensor(v), (vec_broadcast_count, 2))
def h_broadcast_f3(writable, v):
    global vec_broadcast_count
    if writable:
        return torch.tile(get_vm_gpu_tensor(v), (vec_broadcast_count, 1))
    else:
        return torch.broadcast_to(get_vm_gpu_tensor(v), (vec_broadcast_count, 3))
def h_broadcast_f4(writable, v):
    global vec_broadcast_count
    if writable:
        return torch.tile(get_vm_gpu_tensor(v), (vec_broadcast_count, 1))
    else:
        return torch.broadcast_to(get_vm_gpu_tensor(v), (vec_broadcast_count, 4))
def h_broadcast_f3x3(writable, v):
    global vec_broadcast_count
    if writable:
        return torch.tile(get_vm_gpu_tensor(v), (vec_broadcast_count, 1))
    else:
        return torch.broadcast_to(get_vm_gpu_tensor(v), (vec_broadcast_count, 3, 3))

def h_copy_f(v):
    return v
def h_copy_f2(v):
    return torch.clone(v)
def h_copy_f3(v):
    return torch.clone(v)
def h_copy_f4(v):
    return torch.clone(v)
def h_copy_t_f(v):
    return torch.clone(v)
def h_copy_t_f2(v):
    return torch.clone(v)
def h_copy_t_f3(v):
    return torch.clone(v)
def h_copy_t_f4(v):
    return torch.clone(v)
def h_copy_t_i(v):
    return torch.clone(v)
def h_copy_t_i2(v):
    return torch.clone(v)
def h_copy_t_i3(v):
    return torch.clone(v)
def h_copy_t_i4(v):
    return torch.clone(v)

def h_cast_f_h(v):
    return float(v)
def h_cast_f_d(v):
    return float(v)
def h_cast_f_i(v):
    return float(v)
def h_cast_f_u(v):
    return float(v)
def h_cast_f_b(v):
    return 1.0 if v else 0.0

def h_cast_i_h(v):
    return int(v)
def h_cast_i_f(v):
    return int(v)
def h_cast_i_d(v):
    return int(v)
def h_cast_i_u(v):
    return int(v)
def h_cast_i_b(v):
    return 1 if v else 0

def h_cast_u_h(v):
    return int(v)+(1<<32)
def h_cast_u_f(v):
    return int(v)+(1<<32)
def h_cast_u_d(v):
    return int(v)+(1<<32)
def h_cast_u_i(v):
    r = v if v >= 0 else v + (1 << 32)
    return r
def h_cast_u_b(v):
    return 1 if v else 0

def h_cast_b_h(v):
    return int(v) != 0
def h_cast_b_f(v):
    return int(v) != 0
def h_cast_b_d(v):
    return int(v) != 0
def h_cast_b_i(v):
    return int(v) != 0
def h_cast_b_u(v):
    return int(v) != 0

def h_cast_f2_i2(v):
    return v.float()
def h_cast_f2_h2(v):
    return v.float()
def h_cast_f2_d2(v):
    return v.float()
def h_cast_f2_u2(v):
    return v.float()
def h_cast_f2_b2(v):
    return v.float()
def h_cast_f2_f(v):
    return get_vm_gpu_tensor([v, v])

def h_cast_f3_i3(v):
    return v.float()
def h_cast_f3_h3(v):
    return v.float()
def h_cast_f3_d3(v):
    return v.float()
def h_cast_f3_u3(v):
    return v.float()
def h_cast_f3_b3(v):
    return v.float()

def h_cast_f4_i4(v):
    return v.float()
def h_cast_f4_h4(v):
    return v.float()
def h_cast_f4_d4(v):
    return v.float()
def h_cast_f4_u4(v):
    return v.float()
def h_cast_f4_b4(v):
    return v.float()

def h_cast_d2_i2(v):
    return v.float()
def h_cast_d2_h2(v):
    return v.float()
def h_cast_d2_f2(v):
    return v.float()
def h_cast_d2_u2(v):
    return v.float()
def h_cast_d2_b2(v):
    return v.float()

def h_cast_d3_i3(v):
    return v.float()
def h_cast_d3_h3(v):
    return v.float()
def h_cast_d3_f3(v):
    return v.float()
def h_cast_d3_u3(v):
    return v.float()
def h_cast_d3_b3(v):
    return v.float()

def h_cast_d4_i4(v):
    return v.float()
def h_cast_d4_h4(v):
    return v.float()
def h_cast_d4_f4(v):
    return v.float()
def h_cast_d4_u4(v):
    return v.float()
def h_cast_d4_b4(v):
    return v.float()

def h_cast_i2_h2(v):
    return v.int()
def h_cast_i2_f2(v):
    return v.int()
def h_cast_i2_d2(v):
    return v.int()
def h_cast_i2_u2(v):
    return v.int()
def h_cast_i2_b2(v):
    return v.int()

def h_cast_i3_h3(v):
    return v.int()
def h_cast_i3_f3(v):
    return v.int()
def h_cast_i3_d3(v):
    return v.int()
def h_cast_i3_u3(v):
    return v.int()
def h_cast_i3_b3(v):
    return v.int()

def h_cast_i4_h4(v):
    return v.int()
def h_cast_i4_f4(v):
    return v.int()
def h_cast_i4_d4(v):
    return v.int()
def h_cast_i4_u4(v):
    return v.int()
def h_cast_i4_b4(v):
    return v.int()

def h_cast_u2_h2(v):
    return v.int()
def h_cast_u2_f2(v):
    return v.int()
def h_cast_u2_d2(v):
    return v.int()
def h_cast_u2_i2(v):
    return v.int()
def h_cast_u2_b2(v):
    return v.int()

def h_cast_t_u_t_i(v):
    return torch.abs(v).type(torch.int64)
def h_cast_t_u2_t_i2(v):
    return torch.abs(v).type(torch.int64)
def h_cast_t_u_t_f(v):
    return torch.abs(v).type(torch.int64)
def h_cast_t_u2_t_f2(v):
    return torch.abs(v).type(torch.int64)

def h_cast_u3_h3(v):
    return v.int()
def h_cast_u3_f3(v):
    return v.int()
def h_cast_u3_d3(v):
    return v.int()
def h_cast_u3_i3(v):
    return v.int()
def h_cast_u3_b3(v):
    return v.int()

def h_cast_u4_h4(v):
    return v.int()
def h_cast_u4_f4(v):
    return v.int()
def h_cast_u4_d4(v):
    return v.int()
def h_cast_u4_i4(v):
    return v.int()
def h_cast_u4_b4(v):
    return v.int()

def h_cast_h2_f2(v):
    return v.float()
def h_cast_h2_d2(v):
    return v.float()
def h_cast_h2_i2(v):
    return v.float()
def h_cast_h2_u2(v):
    return v.float()
def h_cast_h2_b2(v):
    return v.float()

def h_cast_h3_f3(v):
    return v.float()
def h_cast_h3_d3(v):
    return v.float()
def h_cast_h3_i3(v):
    return v.float()
def h_cast_h3_u3(v):
    return v.float()
def h_cast_h3_b3(v):
    return v.float()

def h_cast_h4_f4(v):
    return v.float()
def h_cast_h4_d4(v):
    return v.float()
def h_cast_h4_i4(v):
    return v.float()
def h_cast_h4_u4(v):
    return v.float()
def h_cast_h4_b4(v):
    return v.float()

def h_cast_b2_h2(v):
    return v.int()
def h_cast_b2_f2(v):
    return v.int()
def h_cast_b2_d2(v):
    return v.int()
def h_cast_b2_i2(v):
    return v.int()
def h_cast_b2_u2(v):
    return v.int()

def h_cast_b3_h3(v):
    return v.int()
def h_cast_b3_f3(v):
    return v.int()
def h_cast_b3_d3(v):
    return v.int()
def h_cast_b3_i3(v):
    return v.int()
def h_cast_b3_u3(v):
    return v.int()

def h_cast_b4_h4(v):
    return v.int()
def h_cast_b4_f4(v):
    return v.int()
def h_cast_b4_d4(v):
    return v.int()
def h_cast_b4_i4(v):
    return v.int()
def h_cast_b4_u4(v):
    return v.int()

def h_cast_f_f(v):
    return v
def h_cast_f2_f2(v):
    return v
def h_cast_f3_f3(v):
    return v
def h_cast_f4_f4(v):
    return v

def h_cast_f2_f3(v):
    return torch.asarray([v[0], v[1]])
def h_cast_f3_f4(v):
    return torch.asarray([v[0], v[1], v[2]])

def h_cast_i_i(v):
    return v
def h_cast_i2_i2(v):
    return v
def h_cast_i3_i3(v):
    return v
def h_cast_i4_i4(v):
    return v

def h_cast_b_b(v):
    return v
def h_cast_b2_b2(v):
    return v
def h_cast_b3_b3(v):
    return v
def h_cast_b4_b4(v):
    return v

def h_cast_f3x3_i_x9(v):
    return h_f3x3_n_n_n_n_n_n_n_n_n(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8])
def h_cast_t_f3x3_t_f_x9(v):
    return h_t_f3x3_t_n_t_n_t_n_t_n_t_n_t_n_t_n_t_n_t_n(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8])
def h_cast_f4x4_i_x16(v):
    return h_f4x4_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12], v[13], v[14], v[15])

def h_cast_t_f_t_f(v):
    return v
def h_cast_t_f2_t_f2(v):
    return v
def h_cast_t_f3_t_f3(v):
    return v
def h_cast_t_f4_t_f4(v):
    return v
def h_cast_t_i_t_i(v):
    return v
def h_cast_t_i2_t_i2(v):
    return v
def h_cast_t_i3_t_i3(v):
    return v
def h_cast_t_i4_t_i4(v):
    return v
def h_cast_t_f_t_i(v):
    return v.float()
def h_cast_t_f_t_u(v):
    return v.float()
def h_cast_t_i_t_f(v):
    return v.int()
def h_cast_t_i_t_b(v):
    return v.int()
def h_cast_t_i2_t_f2(v):
    return v.int()
def h_cast_t_i3_t_f3(v):
    return v.int()
def h_cast_t_i4_t_f4(v):
    return v.int()
def h_cast_t_f2_t_u2(v):
    return v.float()
def h_cast_t_f3_t_u3(v):
    return v.float()
def h_cast_t_f_t_b(v):
    return v.float()


def h_f2_n_n(x, y):
    return torch.asarray([x, y], device=device)

def h_t_f2_t_n_n(x, y):
    xs = x
    ys = torch.broadcast_to(get_s_gpu_tensor(y), [len(x)])
    xs = get_gpu_value(xs)
    ys = get_gpu_value(ys)
    nv = torch.column_stack((xs, ys))
    return nv

def h_t_f2_n_t_n(x, y):    
    xs = torch.broadcast_to(get_s_gpu_tensor(x), [len(y)])
    ys = y
    xs = get_gpu_value(xs)
    ys = get_gpu_value(ys)
    nv = torch.column_stack((xs, ys))
    return nv
def h_t_f2_t_n_t_n(x, y):
    nv = torch.column_stack((x, y))
    nv = get_gpu_value(nv)
    return nv

def h_f3_x_y(x, y):
    xisv = maybe_svm_array(x)
    yisv = maybe_svm_array(y)
    if xisv or yisv:
        nx = 0
        ny = 0
        if xisv:
            nx = len(x)
        if yisv:
            ny = len(y)
        mn = max(nx, ny)
        xs = x
        if not xisv:
            xs = torch.broadcast_to(get_s_gpu_tensor(x), [mn])
        ys = y
        if not yisv:
            ys = torch.broadcast_to(get_s_gpu_tensor(y), [mn])
        xs = get_gpu_value(xs)
        ys = get_gpu_value(ys)
        nv = torch.column_stack((xs, ys))
        return nv
    else:
        if type(x) == torch.Tensor and x.dim() > 0 and len(x) >= 2:
            return torch.asarray([x[0], x[1], y], device=device)
        elif type(y) == torch.Tensor and y.dim() > 0 and len(y) >= 2:
            return torch.asarray([x, y[0], y[1]], device=device)
        else:
            return torch.asarray([x, y, 1.0], device=device)
def h_f3_x_y_z(x, y, z):
    xisv = maybe_svm_array(x)
    yisv = maybe_svm_array(y)
    zisv = maybe_svm_array(z)
    if xisv or yisv or zisv:
        nx = 0
        ny = 0
        nz = 0
        if xisv:
            nx = len(x)
        if yisv:
            ny = len(y)
        if zisv:
            nz = len(z)
        mn = max(nx, ny, nz)
        xs = x
        if not xisv:
            xs = torch.broadcast_to(get_s_gpu_tensor(x), [mn])
        ys = y
        if not yisv:
            ys = torch.broadcast_to(get_s_gpu_tensor(y), [mn])
        zs = z
        if not zisv:
            zs = torch.broadcast_to(get_s_gpu_tensor(z), [mn])
        nv = torch.column_stack((xs, ys, zs))
        return nv
    else:
        return torch.asarray([x, y, z], device=device)
def h_f3_n2_n(x, y):
    return torch.asarray([x[0], x[1], y], device=device)
def h_f3_n_n2(x, y):
    return torch.asarray([x, y[0], y[1]], device=device)
def h_f3_n_n(x, y):
    return torch.asarray([x, y, 1.0], device=device)
def h_f3_n_n_n(x, y, z):
    return torch.asarray([x, y, z], device=device)

def h_t_f3_t_n_t_n_t_n(x, y, z):
    return torch.column_stack((x, y, z))
def h_t_f3_t_n2_t_n(x, y):
    xs = get_gpu_value(x)
    ys = get_gpu_value(y)
    nv = torch.column_stack((xs, ys))
    return nv
def h_t_f3_t_n_t_n2(x, y):
    xs = get_gpu_value(x)
    ys = get_gpu_value(y)
    nv = torch.column_stack((xs, ys))
    return nv
def h_t_f3_t_n2_n(x, y):
    ys = torch.broadcast_to(get_s_gpu_tensor(y), [len(x)])
    ys = get_gpu_value(ys)
    return torch.column_stack((x, ys))
def h_t_f3_t_n_t_n_n(x, y, z):
    zs = torch.broadcast_to(get_s_gpu_tensor(z), [len(x)])
    zs = get_gpu_value(zs)
    return torch.column_stack((x, y, zs))
def h_t_f3_t_n_n_n(x, y, z):
    ys = torch.broadcast_to(get_s_gpu_tensor(y), [len(x)])
    zs = torch.broadcast_to(get_s_gpu_tensor(z), [len(x)])
    ys = get_gpu_value(ys)
    zs = get_gpu_value(zs)
    return torch.column_stack((x, ys, zs))
def h_t_f3_t_n_n_t_n(x, y, z):
    ys = torch.broadcast_to(get_s_gpu_tensor(y), [len(x)])
    ys = get_gpu_value(ys)
    return torch.column_stack((x, ys, z))
def h_t_f3_n_t_n_n(x, y, z):
    xs = torch.broadcast_to(get_s_gpu_tensor(x), [len(y)])
    zs = torch.broadcast_to(get_s_gpu_tensor(z), [len(y)])
    xs = get_gpu_value(xs)
    zs = get_gpu_value(zs)
    return torch.column_stack((xs, y, zs))
def h_t_f3_n_t_n_t_n(x, y, z):
    xs = torch.broadcast_to(get_s_gpu_tensor(x), [len(y)])
    xs = get_gpu_value(xs)
    return torch.column_stack((xs, y, z))
def h_t_f3_n_t_n2(x, yz):
    xs = torch.broadcast_to(get_s_gpu_tensor(x), [len(yz)])
    xs = get_gpu_value(xs)
    return torch.column_stack((xs, yz))

def h_f4_x_y(x, y):
    xisv = maybe_svm_array(x)
    yisv = maybe_svm_array(y)
    if xisv or yisv:
        nx = 0
        ny = 0
        if xisv:
            nx = len(x)
        if yisv:
            ny = len(y)
        mn = max(nx, ny)
        xs = x
        if not xisv:
            xs = torch.repeat_interleave(x, mn)
        ys = y
        if not yisv:
            ys = torch.repeat_interleave(y, mn)
        nv = torch.column_stack((xs, ys))
        return nv
    else:
        if type(x) == torch.Tensor and x.dim() > 0 and type(y) == torch.Tensor and y.dim() > 0:
            return torch.asarray([x[0], x[1], y[0], y[1]], device=device)
        elif type(x) == torch.Tensor and x.dim() > 0:
            return torch.asarray([x[0], x[1], x[2], y], device=device)
        elif type(y) == torch.Tensor and y.dim() > 0:
            return torch.asarray([x, y[0], y[1], y[2]], device=device)
def h_f4_x_y_z(x, y, z):
    xisv = maybe_svm_array(x)
    yisv = maybe_svm_array(y)
    zisv = maybe_svm_array(z)
    if xisv or yisv or zisv:
        nx = 0
        ny = 0
        nz = 0
        if xisv:
            nx = len(x)
        if yisv:
            ny = len(y)
        if zisv:
            nz = len(z)
        mn = max(nx, ny, nz)
        xs = x
        if not xisv:
            xs = torch.repeat_interleave(x, mn)
        ys = y
        if not yisv:
            ys = torch.repeat_interleave(y, mn)
        zs = z
        if not zisv:
            zs = torch.repeat_interleave(z, mn)
        ws = torch.repeat_interleave(1.0, mn)
        nv = torch.column_stack((xs, ys, zs, ws))
        return nv
    else:
        return torch.asarray([x, y, z, 1.0], device=device)
def h_f4_x_y_z_w(x, y, z, w):
    xisv = maybe_svm_array(x)
    yisv = maybe_svm_array(y)
    zisv = maybe_svm_array(z)
    wisv = maybe_svm_array(w)
    if xisv or yisv or zisv or wisv:
        nx = 0
        ny = 0
        nz = 0
        nw = 0
        if xisv:
            nx = len(x)
        if yisv:
            ny = len(y)
        if zisv:
            nz = len(z)
        if wisv:
            nw = len(w)
        mn = max(nx, ny, nz, nw)
        xs = x
        if not xisv:
            xs = torch.repeat_interleave(x, mn)
        ys = y
        if not yisv:
            ys = torch.repeat_interleave(y, mn)
        zs = z
        if not zisv:
            zs = torch.repeat_interleave(z, mn)
        ws = w
        if not wisv:
            ws = torch.repeat_interleave(w, mn)
        nv = torch.column_stack((xs, ys, zs, ws))
        return nv
    else:
        return torch.asarray([x, y, z, w], device=device)

def h_f4_n3_n(x, y):
    return torch.asarray([x[0], x[1], x[2], y], device=device)
def h_f4_n2_n2(x, y):
    return torch.asarray([x[0], x[1], y[0], y[1]], device=device)
def h_f4_n_n3(x, y):
    return torch.asarray([x, y[0], y[1], y[2]], device=device)
def h_f4_n2_n_n(x, y, z):
    return torch.asarray([x[0], x[1], y, z], device=device)
def h_f4_n_n_n(x, y, z):
    return torch.asarray([x, y, z, 1.0], device=device)
def h_f4_n_n_n_n(x, y, z, w):
    return torch.asarray([x, y, z, w], device=device)

def h_t_f4_t_n_t_n_t_n_t_n(x, y, z, w):
    return torch.column_stack((x, y, z, w))
def h_t_f4_t_n_t_n_t_n_n(x, y, z, w):
    w = torch.broadcast_to(get_s_gpu_tensor(w), [len(x)])
    w = get_gpu_value(w)
    return torch.column_stack((x, y, z, w))
def h_t_f4_t_n2_t_n2(x, y):
    return torch.column_stack((x, y))
def h_t_f4_t_n2_t_n_n(xy, z, w):
    w = torch.broadcast_to(get_s_gpu_tensor(w), [len(xy)])
    w = get_gpu_value(w)
    return torch.column_stack((xy, z, w))
def h_t_f4_t_n2_n_t_n(xy, z, w):
    z = torch.broadcast_to(get_s_gpu_tensor(z), [len(xy)])
    return torch.column_stack((xy, z, w))
def h_t_f4_t_n2_n_n(xy, z, w):
    z = torch.broadcast_to(get_s_gpu_tensor(z), [len(xy)])
    w = torch.broadcast_to(get_s_gpu_tensor(w), [len(xy)])
    return torch.column_stack((xy, z, w))
def h_t_f4_t_n3_n(x, y):
    y = torch.broadcast_to(get_s_gpu_tensor(y), [len(x)])
    x = get_gpu_value(x)
    y = get_gpu_value(y)
    return torch.column_stack((x, y))
def h_t_f4_t_n_t_n3(x, y):
    return torch.column_stack((x, y))
def h_t_f4_t_n3_t_n(x, y):
    return torch.column_stack((x, y))
def h_t_f4_t_n_t_n_n_n(x, y, z, w):
    zs = torch.broadcast_to(get_s_gpu_tensor(z), [len(x)])
    ws = torch.broadcast_to(get_s_gpu_tensor(w), [len(x)])
    zs = get_gpu_value(zs)
    ws = get_gpu_value(ws)
    return torch.column_stack((x, y, zs, ws))

def h_t_f4_t_n_n_t_n_n(x, y, z, w):
    ys = torch.broadcast_to(get_s_gpu_tensor(y), [len(x)])
    ws = torch.broadcast_to(get_s_gpu_tensor(w), [len(x)])
    ys = get_gpu_value(ys)
    ws = get_gpu_value(ws)
    return torch.column_stack((x, ys, z, ws))
def h_t_f4_t_n_n_n_t_n(x, y, z, w):
    ys = torch.broadcast_to(get_s_gpu_tensor(y), [len(x)])
    zs = torch.broadcast_to(get_s_gpu_tensor(z), [len(x)])
    ys = get_gpu_value(ys)
    zs = get_gpu_value(zs)
    return torch.column_stack((x, ys, zs, w))
def h_t_f4_n_t_n_t_n_n(x, y, z, w):
    xs = torch.broadcast_to(get_s_gpu_tensor(x), [len(y)])
    ws = torch.broadcast_to(get_s_gpu_tensor(w), [len(y)])
    xs = get_gpu_value(xs)
    ws = get_gpu_value(ws)
    return torch.column_stack((xs, y, z, ws))
def h_t_f4_n_t_n_n_t_n(x, y, z, w):
    xs = torch.broadcast_to(get_s_gpu_tensor(x), [len(w)])
    zs = torch.broadcast_to(get_s_gpu_tensor(z), [len(w)])
    xs = get_gpu_value(xs)
    zs = get_gpu_value(zs)
    return torch.column_stack((xs, y, zs, w))
def h_t_f4_n_n_t_n_t_n(x, y, z, w):
    xs = torch.broadcast_to(get_s_gpu_tensor(x), [len(w)])
    ys = torch.broadcast_to(get_s_gpu_tensor(y), [len(w)])
    xs = get_gpu_value(xs)
    ys = get_gpu_value(ys)
    return torch.column_stack((xs, ys, z, w))
def h_t_f4_t_n_n_n_n(x, y, z, w):
    ys = torch.broadcast_to(get_s_gpu_tensor(y), [len(x)])
    zs = torch.broadcast_to(get_s_gpu_tensor(z), [len(x)])
    ws = torch.broadcast_to(get_s_gpu_tensor(w), [len(x)])
    ys = get_gpu_value(ys)
    zs = get_gpu_value(zs)
    ws = get_gpu_value(ws)
    return torch.column_stack((x, ys, zs, ws))
def h_t_f4_n_t_n_n_n(x, y, z, w):
    xs = torch.broadcast_to(get_s_gpu_tensor(x), [len(y)])
    zs = torch.broadcast_to(get_s_gpu_tensor(z), [len(y)])
    ws = torch.broadcast_to(get_s_gpu_tensor(w), [len(y)])
    xs = get_gpu_value(xs)
    zs = get_gpu_value(zs)
    ws = get_gpu_value(ws)
    return torch.column_stack((xs, y, zs, ws))
def h_t_f4_n_n_t_n_n(x, y, z, w):
    xs = torch.broadcast_to(get_s_gpu_tensor(x), [len(z)])
    ys = torch.broadcast_to(get_s_gpu_tensor(y), [len(z)])
    ws = torch.broadcast_to(get_s_gpu_tensor(w), [len(z)])
    xs = get_gpu_value(xs)
    ys = get_gpu_value(ys)
    ws = get_gpu_value(ws)
    return torch.column_stack((xs, ys, z, ws))
def h_t_f4_n_n_n_t_n(x, y, z, w):
    xs = torch.broadcast_to(get_s_gpu_tensor(x), [len(w)])
    ys = torch.broadcast_to(get_s_gpu_tensor(y), [len(w)])
    zs = torch.broadcast_to(get_s_gpu_tensor(z), [len(w)])
    xs = get_gpu_value(xs)
    ys = get_gpu_value(ys)
    zs = get_gpu_value(zs)
    return torch.column_stack((xs, ys, zs, w))
def h_t_f4_n3_t_n(xyz, w):
    xyz = torch.broadcast_to(get_vm_gpu_tensor(xyz), (len(w), 3))
    xyz = get_gpu_value(xyz)
    w = get_gpu_value(w)
    return torch.column_stack((xyz, w))
def h_t_f4_t_n2_t_n_n(xy, z, w):
    ws = torch.broadcast_to(get_s_gpu_tensor(w), [len(z)])
    ws = get_gpu_value(ws)
    return torch.column_stack((xy, z, ws))
def h_t_f4_n_t_n2_n(x, yz, w):
    xs = torch.broadcast_to(get_s_gpu_tensor(x), [len(yz)])
    ws = torch.broadcast_to(get_s_gpu_tensor(w), [len(yz)])
    xs = get_gpu_value(xs)
    ws = get_gpu_value(ws)
    return torch.column_stack((xs, yz, ws))

def h_d2_n_n(x, y):
    return h_f2_n_n(x, y)

def h_d3_n2_n(x, y):
    return h_f3_n2_n(x, y)
def h_d3_n_n_n(x, y, z):
    return h_f3_n_n_n(x, y, z)

def h_d4_n3_n(x, y):
    return h_f4_n3_n(x, y)
def h_d4_n2_n_n(x, y, z):
    return h_f4_n2_n_n(x, y, z)
def h_d4_n_n_n_n(x, y, z, w):
    return h_f4_n_n_n_n(x, y, z, w)

def h_h2_n_n(x, y):
    return h_f2_n_n(x, y)

def h_h3_n2_n(x, y):
    return h_f3_n2_n(x, y)
def h_h3_n_n_n(x, y, z):
    return h_f3_n_n_n(x, y, z)

def h_h4_n3_n(x, y):
    return h_f4_n3_n(x, y)
def h_h4_n2_n_n(x, y, z):
    return h_f4_n2_n_n(x, y, z)
def h_h4_n_n_n_n(x, y, z, w):
    return h_f4_n_n_n_n(x, y, z, w)

def h_i2_n_n(x, y):
    return h_f2_n_n(x, y)

def h_i3_n2_n(x, y):
    return h_f3_n2_n(x, y)
def h_i3_n_n_n(x, y, z):
    return h_f3_n_n_n(x, y, z)
def h_t_i3_t_n2_n(x, y):
    return h_t_f3_t_n2_n(x, y)

def h_i4_n3_n(x, y):
    return h_f4_n3_n(x, y)
def h_i4_n2_n_n(x, y, z):
    return h_f4_n2_n_n(x, y, z)
def h_i4_n_n_n_n(x, y, z, w):
    return h_f4_n_n_n_n(x, y, z, w)

def h_b2_n_n(x, y):
    return h_f2_n_n(x, y)
def h_t_b2_t_n_t_n(x, y):
    return h_t_f2_t_n_t_n(x, y)

def h_b3_n2_n(x, y):
    return h_f3_n2_n(x, y)
def h_b3_n_n_n(x, y, z):
    return h_f3_n_n_n(x, y, z)
def h_t_b3_t_n_t_n_t_n(x, y, z):
    return h_t_f3_t_n_t_n_t_n(x, y, z)

def h_b4_n3_n(x, y):
    return h_f4_n3_n(x, y)
def h_b4_n2_n_n(x, y, z):
    return h_f4_n2_n_n(x, y, z)
def h_b4_n_n_n_n(x, y, z, w):
    return h_f4_n_n_n_n(x, y, z, w)

def h_u2_n_n(x, y):
    return h_f2_n_n(x, y)
def h_t_u2_t_n_t_n(x, y):
    return torch.column_stack((x, y))

def h_u3_n2_n(x, y):
    return h_f3_n2_n(x, y)
def h_u3_n_n_n(x, y, z):
    return h_f3_n_n_n(x, y, z)
def h_t_u3_t_n_t_n_t_n(x, y, z):
    return torch.column_stack((x, y, z))

def h_u4_n3_n(x, y):
    return h_f4_n3_n(x, y)
def h_u4_n2_n_n(x, y, z):
    return h_f4_n2_n_n(x, y, z)
def h_u4_n_n_n_n(x, y, z, w):
    return h_f4_n_n_n_n(x, y, z, w)

def h_f2x2_n_n_n_n(x1, y1, x2, y2):
    return torch.asarray([[x1, y1], [x2, y2]], device=device)
def h_f2x2_n2_n2(x, y):
    return torch.stack((x, y))
def h_t_f2x2_t_n_t_n_t_n_t_n(x1, y1, x2, y2):
    r1 = torch.column_stack((x1, y1))
    r2 = torch.column_stack((x2, y2))
    return torch.stack((r1, r2), axis=1)

def h_t_f2x2_t_n2_t_n2(xy1, xy2):
    return torch.stack((xy1, xy2), axis=1)

def h_f3x3_n_n_n_n_n_n_n_n_n(x1, y1, z1, x2, y2, z2, x3, y3, z3):
    return torch.asarray([[x1, y1, z1], [x2, y2, z2], [x3, y3, z3]], device=device)
def h_f3x3_n3_n3_n3(x, y, z):
    return torch.stack((x, y, z))
def h_t_f3x3_t_n_t_n_t_n_t_n_t_n_t_n_t_n_t_n_t_n(x1, y1, z1, x2, y2, z2, x3, y3, z3):
    r1 = torch.column_stack((x1, y1, z1))
    r2 = torch.column_stack((x2, y2, z2))
    r3 = torch.column_stack((x3, y3, z3))
    return torch.stack((r1, r2, r3), axis=1)
def h_t_f3x3_t_n3_t_n3_t_n3(v1, v2, v3):
    return torch.stack((v1, v2, v3), axis=1)

def h_f4x4_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n(x1, y1, z1, w1, x2, y2, z2, w2, x3, y3, z3, w3, x4, y4, z4, w4):
    return torch.asarray([[x1, y1, z1, w1], [x2, y2, z2, w2], [x3, y3, z3, w3], [x4, y4, z4, w4]], device=device)
def h_f4x4_n4_n4_n4_n4(x, y, z, w):
    return torch.stack((x, y, z, w))
def h_t_f4x4_t_n_t_n_t_n_n_t_n_t_n_t_n_n_t_n_t_n_t_n_n_n_n_n_n(xs1, ys1, zs1, w1, xs2, ys2, zs2, w2, xs3, ys3, zs3, w3, x4, y4, z4, w4):
    n = len(xs1)
    ws1 = torch.broadcast_to(get_s_gpu_tensor(w1), [n])
    ws2 = torch.broadcast_to(get_s_gpu_tensor(w2), [n])
    ws3 = torch.broadcast_to(get_s_gpu_tensor(w3), [n])
    xs4 = torch.broadcast_to(get_s_gpu_tensor(x4), [n])
    ys4 = torch.broadcast_to(get_s_gpu_tensor(y4), [n])
    zs4 = torch.broadcast_to(get_s_gpu_tensor(z4), [n])
    ws4 = torch.broadcast_to(get_s_gpu_tensor(w4), [n])
    r1 = torch.column_stack((xs1, ys1, zs1, ws1))
    r2 = torch.column_stack((xs2, ys2, zs2, ws2))
    r3 = torch.column_stack((xs3, ys3, zs3, ws3))
    r4 = torch.column_stack((xs4, ys4, zs4, ws4))
    return torch.stack((r1, r2, r3, r4), axis=1)
def h_t_f4x4_t_n4_t_n4_t_n4_t_n4(x, y, z, w):
    return torch.stack((x, y, z, w), axis=1)
def h_t_f4x4_t_n4_t_n4_t_n4_n4(x, y, z, w):
    n = len(x)
    ws = torch.broadcast_to(get_vm_gpu_tensor(w), (n, 4))
    return torch.stack((x, y, z, ws), axis=1)

def h_d2x2_n_n_n_n(x1, y1, x2, y2):
    return torch.asarray([[x1, y1], [x2, y2]], device=device)

def h_d3x3_n_n_n_n_n_n_n_n_n(x1, y1, z1, x2, y2, z2, x3, y3, z3):
    return torch.asarray([[x1, y1, z1], [x2, y2, z2], [x3, y3, z3]], device=device)

def h_d4x4_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n(x1, y1, z1, w1, x2, y2, z2, w2, x3, y3, z3, w3, x4, y4, z4, w4):
    return torch.asarray([[x1, y1, z1, w1], [x2, y2, z2, w2], [x3, y3, z3, w3], [x4, y4, z4, w4]], device=device)

def h_h2x2_n_n_n_n(x1, y1, x2, y2):
    return torch.asarray([[x1, y1], [x2, y2]], device=device)

def h_h3x3_n_n_n_n_n_n_n_n_n(x1, y1, z1, x2, y2, z2, x3, y3, z3):
    return torch.asarray([[x1, y1, z1], [x2, y2, z2], [x3, y3, z3]], device=device)

def h_h4x4_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n(x1, y1, z1, w1, x2, y2, z2, w2, x3, y3, z3, w3, x4, y4, z4, w4):
    return torch.asarray([[x1, y1, z1, w1], [x2, y2, z2, w2], [x3, y3, z3, w3], [x4, y4, z4, w4]], device=device)

def h_i2x2_n_n_n_n(x1, y1, x2, y2):
    return h_f2x2_n_n_n_n(x1, y1, x2, y2)
def h_i3x3_n_n_n_n_n_n_n_n_n(x1, y1, z1, x2, y2, z2, x3, y3, z3):
    return h_f3x3_n_n_n_n_n_n_n_n_n(x1, y1, z1, x2, y2, z2, x3, y3, z3)
def h_i4x4_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n(x1, y1, z1, w1, x2, y2, z2, w2, x3, y3, z3, w3, x4, y4, z4, w4):
    return h_f4x4_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n(x1, y1, z1, w1, x2, y2, z2, w2, x3, y3, z3, w3, x4, y4, z4, w4)

def h_b2x2_n_n_n_n(x1, y1, x2, y2):
    return h_f2x2_n_n_n_n(x1, y1, x2, y2)
def h_b3x3_n_n_n_n_n_n_n_n_n(x1, y1, z1, x2, y2, z2, x3, y3, z3):
    return h_f3x3_n_n_n_n_n_n_n_n_n(x1, y1, z1, x2, y2, z2, x3, y3, z3)
def h_b4x4_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n(x1, y1, z1, w1, x2, y2, z2, w2, x3, y3, z3, w3, x4, y4, z4, w4):
    return h_f4x4_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n(x1, y1, z1, w1, x2, y2, z2, w2, x3, y3, z3, w3, x4, y4, z4, w4)

def h_u2x2_n_n_n_n(x1, y1, x2, y2):
    return h_f2x2_n_n_n_n(x1, y1, x2, y2)
def h_u3x3_n_n_n_n_n_n_n_n_n(x1, y1, z1, x2, y2, z2, x3, y3, z3):
    return h_f3x3_n_n_n_n_n_n_n_n_n(x1, y1, z1, x2, y2, z2, x3, y3, z3)
def h_u4x4_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n(x1, y1, z1, w1, x2, y2, z2, w2, x3, y3, z3, w3, x4, y4, z4, w4):
    return h_f4x4_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n_n(x1, y1, z1, w1, x2, y2, z2, w2, x3, y3, z3, w3, x4, y4, z4, w4)

def h_f2_defval():
    return new_zero_tensor(2)
def h_f3_defval():
    return new_zero_tensor(3)
def h_f4_defval():
    return new_zero_tensor(4)
def h_f2x2_defval():
    return new_zero_tensor(2, 2)
def h_f3x3_defval():
    return new_zero_tensor(3, 3)
def h_f4x4_defval():
    return new_zero_tensor(4, 4)
def h_af_defval(num):
    return new_zero_tensor(num)
def h_af2_defval(num):
    return new_zero_tensor(num, 2)
def h_af3_defval(num):
    return new_zero_tensor(num, 3)
def h_af4_defval(num):
    return new_zero_tensor(num, 4)
def h_ab_defval(num):
    return new_false_tensor(num)
def h_ai_defval(num):
    return new_zero_int_tensor(num)

def h_t_b_defval(writable):
    global vec_broadcast_count
    if writable:
        return torch.tile(gpu_zero_tensor, [vec_broadcast_count]).bool()
    else:
        return torch.broadcast_to(gpu_zero_tensor, [vec_broadcast_count]).bool()
def h_t_i_defval(writable):
    global vec_broadcast_count
    if writable:
        return torch.tile(gpu_zero_tensor, [vec_broadcast_count]).int()
    else:
        return torch.broadcast_to(gpu_zero_tensor, [vec_broadcast_count]).int()
def h_t_f_defval(writable):
    global vec_broadcast_count
    if writable:
        return torch.tile(gpu_zero_tensor, [vec_broadcast_count])
    else:
        return torch.broadcast_to(gpu_zero_tensor, [vec_broadcast_count])
def h_t_f2_defval(writable):
    global vec_broadcast_count
    if writable:
        return torch.tile(gpu_zero_tensor, (vec_broadcast_count, 2))
    else:
        return torch.broadcast_to(gpu_zero_tensor, (vec_broadcast_count, 2))
def h_t_f3_defval(writable):
    global vec_broadcast_count
    if writable:
        return torch.tile(gpu_zero_tensor, (vec_broadcast_count, 3))
    else:
        return torch.broadcast_to(gpu_zero_tensor, (vec_broadcast_count, 3))
def h_t_f4_defval(writable):
    global vec_broadcast_count
    if writable:
        return torch.tile(gpu_zero_tensor, (vec_broadcast_count, 4))
    else:
        return torch.broadcast_to(gpu_zero_tensor, (vec_broadcast_count, 4))
def h_t_f2x2_defval(writable):
    global vec_broadcast_count
    if writable:
        return torch.tile(gpu_zero_tensor, (vec_broadcast_count, 2, 2))
    else:
        return torch.broadcast_to(gpu_zero_tensor, (vec_broadcast_count, 2, 2))
def h_t_f3x3_defval(writable):
    global vec_broadcast_count
    if writable:
        return torch.tile(gpu_zero_tensor, (vec_broadcast_count, 3, 3))
    else:
        return torch.broadcast_to(gpu_zero_tensor, (vec_broadcast_count, 3, 3))
def h_t_f4x4_defval(writable):
    global vec_broadcast_count
    if writable:
        return torch.tile(gpu_zero_tensor, (vec_broadcast_count, 4, 4))
    else:
        return torch.broadcast_to(gpu_zero_tensor, (vec_broadcast_count, 4, 4))
def h_t_af_defval(num, writable):
    global vec_broadcast_count
    if writable:
        return torch.tile(gpu_zero_tensor, (num, vec_broadcast_count))
    else:
        return torch.broadcast_to(gpu_zero_tensor, (num, vec_broadcast_count))
def h_t_af2_defval(num, writable):
    global vec_broadcast_count
    if writable:
        return torch.tile(gpu_zero_tensor, (num, vec_broadcast_count, 2))
    else:
        return torch.broadcast_to(gpu_zero_tensor, (num, vec_broadcast_count, 2))
def h_t_af3_defval(num, writable):
    global vec_broadcast_count
    if writable:
        return torch.tile(gpu_zero_tensor, (num, vec_broadcast_count, 3))
    else:
        return torch.broadcast_to(gpu_zero_tensor, (num, vec_broadcast_count, 3))
def h_t_af4_defval(num, writable):
    global vec_broadcast_count
    if writable:
        return torch.tile(gpu_zero_tensor, (num, vec_broadcast_count, 4))
    else:
        return torch.broadcast_to(gpu_zero_tensor, (num, vec_broadcast_count, 4))
def h_t_ab_defval(num, writable):
    global vec_broadcast_count
    if writable:
        return torch.tile(gpu_zero_tensor, (num, vec_broadcast_count)).bool()
    else:
        return torch.broadcast_to(gpu_zero_tensor, (num, vec_broadcast_count)).bool()
def h_t_ai_defval(num, writable):
    global vec_broadcast_count
    if writable:
        return torch.tile(gpu_zero_tensor, (num, vec_broadcast_count))
    else:
        return torch.broadcast_to(gpu_zero_tensor, (num, vec_broadcast_count))

def Texture2D_Sample_n_v(tex, sampler, coord):
    coord[torch.isnan(coord[...])] = 0
    coord = torch.remainder(coord, 1.0)
    tex = get_gpu_value(tex)
    texSize = get_vm_gpu_tensor(tex.shape)[0:2]
    texSize = get_gpu_value(texSize)
    coord = get_gpu_value(coord)
    icoord = torch.remainder((coord * texSize).int(), texSize)
    col = tex[tuple(icoord)] / 255.0
    if type(col) == torch.Tensor:
        if col.dim() == 1 and len(col) == 3:
            return get_gpu_value(torch.asarray([col[0], col[1], col[2], 1.0]))
        else:
            return col
    return torch.as_tensor([col, col, col, 1.0], device=device)
def Texture2D_SampleBias_n_v_n(tex, sampler, coord, bias):
    return Texture2D_Sample_n_v(tex, sampler, coord)
def Texture2D_Sample_n_t_v(tex, sampler, coord):
    coord[torch.isnan(coord[...])] = 0
    coord = torch.remainder(coord, 1.0)
    tex = get_gpu_value(tex)
    texSize = get_vm_gpu_tensor(tex.shape)[0:2]
    texSize = get_gpu_value(texSize)
    coord = get_gpu_value(coord)
    icoord = torch.remainder((coord * texSize).long(), texSize)
    icoord = tuple(torch.transpose(icoord, 0, 1))
    vs = tex[icoord]
    if len(vs.shape) == 2:
        if len(vs[0]) == 3:
            cols = vs / 255.0
            nv = torch.column_stack((cols, torch.broadcast_to(gpu_one_tensor, [len(cols)])))
            return nv
        else:
            return vs / 255.0
    else:
        cols = vs / 255.0
        ones = get_gpu_ones(len(cols))
        nv = torch.column_stack((cols, cols, cols, ones))
        return nv

def Texture2D_SampleBias_n_t_v_n(tex, sampler, coord, bias):
    return Texture2D_Sample_n_t_v(tex, sampler, coord)
def Texture2D_SampleLevel_n_v_n(tex, sampler, coord, level):
    coord[torch.isnan(coord[...])] = 0
    coord = torch.remainder(coord, 1.0)
    tex = get_gpu_value(tex)
    texSize = get_vm_gpu_tensor(tex.shape)[0:2]
    texSize = get_gpu_value(texSize)
    coord = get_gpu_value(coord)
    icoord = torch.remainder((coord * texSize).int(), texSize)
    col = tex[tuple(icoord)] / 255.0
    if type(col) == torch.Tensor:
        if col.dim() == 1 and len(col) == 3:
            return get_gpu_value(torch.asarray([col[0], col[1], col[2], 1.0]))
        else:
            return col
    return torch.as_tensor([col, col, col, 1.0], device=device)

def Texture2D_SampleLevel_n_t_v_n(tex, sampler, coord, level):
    coord[torch.isnan(coord[...])] = 0
    coord = torch.remainder(coord, 1.0)
    tex = get_gpu_value(tex)
    texSize = get_vm_gpu_tensor(tex.shape)[0:2]
    texSize = get_gpu_value(texSize)
    coord = get_gpu_value(coord)
    icoord = torch.remainder((coord * texSize).long(), texSize)
    icoord = tuple(torch.transpose(icoord, 0, 1))
    vs = tex[icoord]
    if len(vs.shape) == 2:
        if len(vs[0]) == 3:
            cols = vs / 255.0
            nv = torch.column_stack((cols, torch.broadcast_to(gpu_one_tensor, [len(cols)])))
            return nv
        else:
            return vs / 255.0
    else:
        cols = vs / 255.0
        ones = get_gpu_ones(len(cols))
        nv = torch.column_stack((cols, cols, cols, ones))
        return nv

def Texture2D_SampleGrad_n_t_v_t_v_t_v(tex, sampler, coord, ddx, ddy):
    coord[torch.isnan(coord[...])] = 0
    coord = torch.remainder(coord, 1.0)
    tex = get_gpu_value(tex)
    texSize = get_vm_gpu_tensor(tex.shape)[0:2]
    texSize = get_gpu_value(texSize)
    coord = get_gpu_value(coord)
    icoord = torch.remainder((coord * texSize).long(), texSize)
    icoord = tuple(torch.transpose(icoord, 0, 1))
    vs = tex[icoord]
    if len(vs.shape) == 2:
        if len(vs[0]) == 3:
            cols = vs / 255.0
            nv = torch.column_stack((cols, torch.broadcast_to(gpu_one_tensor, [len(cols)])))
            return nv
        else:
            return vs / 255.0
    else:
        cols = vs / 255.0
        ones = get_gpu_ones(len(cols))
        nv = torch.column_stack((cols, cols, cols, ones))
        return nv
def Texture2D_Load_t_v(tex, coord):
    texSize = get_vm_gpu_tensor(tex.shape)
    texSize = get_gpu_value(texSize)
    coord = get_gpu_value(coord)
    n = len(coord)
    icoord = torch.remainder(coord[..., 0:2].int(), texSize[0:2])
    icoord = tuple(torch.transpose(icoord, 0, 1))
    vs = tex[icoord]
    if len(vs.shape) == 2:
        if len(vs[0]) == 3:
            cols = vs / 255.0
            nv = torch.column_stack((cols, torch.broadcast_to(gpu_one_tensor, [len(cols)])))
            return nv
        else:
            return vs / 255.0
    else:
        cols = vs / 255.0
        ones = get_gpu_ones(len(cols))
        nv = torch.column_stack((cols, cols, cols, ones))
        return nv
def TextureCube_Sample_n_v(tex, sampler, coord):
    coord[torch.isnan(coord[...])] = 0
    coord = torch.remainder(coord, 1.0)
    tex = get_gpu_value(tex)
    texSize = get_vm_gpu_tensor(tex.shape)[0:3]
    texSize = get_gpu_value(texSize)
    coord = get_gpu_value(coord)
    icoord = torch.remainder((coord * texSize).int(), texSize)
    col = tex[tuple(icoord)] / 255.0
    if type(col) == torch.Tensor:
        if col.dim() == 1 and len(col) == 3:
            return get_gpu_value(torch.asarray([col[0], col[1], col[2], 1.0]))
        else:
            return col
    return torch.as_tensor([col, col, col, 1.0], device=device)

def TextureCube_Sample_n_t_v(tex, sampler, coord):
    coord[torch.isnan(coord[...])] = 0
    coord = torch.remainder(coord, 1.0)
    tex = get_gpu_value(tex)
    texSize = get_vm_gpu_tensor(tex.shape)[0:3]
    texSize = get_gpu_value(texSize)
    coord = get_gpu_value(coord)
    icoord = torch.remainder((coord * texSize).long(), texSize)
    icoord = tuple(torch.transpose(icoord, 0, 1))
    vs = tex[icoord]
    if len(vs.shape) == 2:
        if len(vs[0]) == 3:
            cols = vs / 255.0
            nv = torch.column_stack((cols, torch.broadcast_to(gpu_one_tensor, [len(cols)])))
            return nv
        else:
            return vs / 255.0
    else:
        cols = vs / 255.0
        ones = get_gpu_ones(len(cols))
        nv = torch.column_stack((cols, cols, cols, ones))
        return nv

def TextureCube_SampleLevel_n_t_v_n(tex, sampler, coord, level):
    return TextureCube_Sample_n_t_v(tex, sampler, coord)
def Texture3D_Sample_n_v(tex, sampler, coord):
    coord[torch.isnan(coord[...])] = 0
    coord = torch.remainder(coord, 1.0)
    tex = get_gpu_value(tex)
    texSize = get_vm_gpu_tensor(tex.shape)[0:3]
    texSize = get_gpu_value(texSize)
    coord = get_gpu_value(coord)
    icoord = torch.remainder((coord * texSize).int(), texSize)
    col = tex[tuple(icoord)] / 255.0
    if type(col) == torch.Tensor:
        if col.dim() == 1 and len(col) == 3:
            return get_gpu_value(torch.asarray([col[0], col[1], col[2], 1.0]))
        else:
            return col
    return torch.as_tensor([col, col, col, 1.0], device=device)
def Texture3D_Sample_n_t_v(tex, sampler, coord):
    coord[torch.isnan(coord[...])] = 0
    coord = torch.remainder(coord, 1.0)
    tex = get_gpu_value(tex)
    texSize = get_vm_gpu_tensor(tex.shape)[0:3]
    texSize = get_gpu_value(texSize)
    coord = get_gpu_value(coord)
    icoord = torch.remainder((coord * texSize).long(), texSize)
    icoord = tuple(torch.transpose(icoord, 0, 1))
    vs = tex[icoord]
    if len(vs.shape) == 2:
        if len(vs[0]) == 3:
            cols = vs / 255.0
            nv = torch.column_stack((cols, torch.broadcast_to(gpu_one_tensor, [len(cols)])))
            return nv
        else:
            return vs / 255.0
    else:
        cols = vs / 255.0
        ones = get_gpu_ones(len(cols))
        nv = torch.column_stack((cols, cols, cols, ones))
        return nv

def Texture2D__float4_T_Sample_n_v(tex, sampler, coord):
    return Texture2D_Sample_n_v(tex, sampler, coord)
def Texture2D__float4_T_Sample_n_t_v(tex, sampler, coord):
    return Texture2D_Sample_n_t_v(tex, sampler, coord)
def Texture2D__float4_T_SampleLevel_n_t_v_n(tex, sampler, coord, level):
    return Texture2D_SampleLevel_n_t_v_n(tex, sampler, coord, level)
def TextureCube__float4_T_Sample_n_t_v(tex, sampler, coord):
    return TextureCube_Sample_n_t_v(tex, sampler, coord)
def TextureCube__float4_T_SampleLevel_n_t_v_n(tex, sampler, coord, level):
    return TextureCube_SampleLevel_n_t_v_n(tex, sampler, coord, level)
def Texture3D__float4_T_Sample_n_t_v(tex, sampler, coord):
    return Texture3D_Sample_n_t_v(tex, sampler, coord)

def Texture2D__float4_T_SampleBias_n_v_n(tex, sampler, coord, bias):
    return Texture2D_SampleBias_n_v_n(tex, sampler, coord, bias)
def Texture2D__float4_T_SampleBias_n_t_v_n(tex, sampler, coord, bias):
    return Texture2D_SampleBias_n_t_v_n(tex, sampler, coord, bias)
def Texture2D__float4_T_SampleGrad_n_t_v_t_v_t_v(tex, sampler, coord, ddx, ddy):
    return Texture2D_SampleGrad_n_t_v_t_v_t_v(tex, sampler, coord, ddx, ddy)
def Texture2D__float4_T_Load_t_v(tex, coord):
    return Texture2D_Load_t_v(tex, coord)


#----------------------------------------
# these code generated from gen_hlsl_lib_numpy_swizzle.dsl
#---begin---

g_x_index = torch.asarray([0], device=device).squeeze(0)
g_y_index = torch.asarray([1], device=device).squeeze(0)
g_z_index = torch.asarray([2], device=device).squeeze(0)
g_w_index = torch.asarray([3], device=device).squeeze(0)
g_xx_index = torch.asarray([0, 0], device=device)
g_xy_index = torch.asarray([0, 1], device=device)
g_xz_index = torch.asarray([0, 2], device=device)
g_xw_index = torch.asarray([0, 3], device=device)
g_yx_index = torch.asarray([1, 0], device=device)
g_yy_index = torch.asarray([1, 1], device=device)
g_yz_index = torch.asarray([1, 2], device=device)
g_yw_index = torch.asarray([1, 3], device=device)
g_zx_index = torch.asarray([2, 0], device=device)
g_zy_index = torch.asarray([2, 1], device=device)
g_zz_index = torch.asarray([2, 2], device=device)
g_zw_index = torch.asarray([2, 3], device=device)
g_wx_index = torch.asarray([3, 0], device=device)
g_wy_index = torch.asarray([3, 1], device=device)
g_wz_index = torch.asarray([3, 2], device=device)
g_ww_index = torch.asarray([3, 3], device=device)
g_xxx_index = torch.asarray([0, 0, 0], device=device)
g_xxy_index = torch.asarray([0, 0, 1], device=device)
g_xxz_index = torch.asarray([0, 0, 2], device=device)
g_xxw_index = torch.asarray([0, 0, 3], device=device)
g_xyx_index = torch.asarray([0, 1, 0], device=device)
g_xyy_index = torch.asarray([0, 1, 1], device=device)
g_xyz_index = torch.asarray([0, 1, 2], device=device)
g_xyw_index = torch.asarray([0, 1, 3], device=device)
g_xzx_index = torch.asarray([0, 2, 0], device=device)
g_xzy_index = torch.asarray([0, 2, 1], device=device)
g_xzz_index = torch.asarray([0, 2, 2], device=device)
g_xzw_index = torch.asarray([0, 2, 3], device=device)
g_xwx_index = torch.asarray([0, 3, 0], device=device)
g_xwy_index = torch.asarray([0, 3, 1], device=device)
g_xwz_index = torch.asarray([0, 3, 2], device=device)
g_xww_index = torch.asarray([0, 3, 3], device=device)
g_yxx_index = torch.asarray([1, 0, 0], device=device)
g_yxy_index = torch.asarray([1, 0, 1], device=device)
g_yxz_index = torch.asarray([1, 0, 2], device=device)
g_yxw_index = torch.asarray([1, 0, 3], device=device)
g_yyx_index = torch.asarray([1, 1, 0], device=device)
g_yyy_index = torch.asarray([1, 1, 1], device=device)
g_yyz_index = torch.asarray([1, 1, 2], device=device)
g_yyw_index = torch.asarray([1, 1, 3], device=device)
g_yzx_index = torch.asarray([1, 2, 0], device=device)
g_yzy_index = torch.asarray([1, 2, 1], device=device)
g_yzz_index = torch.asarray([1, 2, 2], device=device)
g_yzw_index = torch.asarray([1, 2, 3], device=device)
g_ywx_index = torch.asarray([1, 3, 0], device=device)
g_ywy_index = torch.asarray([1, 3, 1], device=device)
g_ywz_index = torch.asarray([1, 3, 2], device=device)
g_yww_index = torch.asarray([1, 3, 3], device=device)
g_zxx_index = torch.asarray([2, 0, 0], device=device)
g_zxy_index = torch.asarray([2, 0, 1], device=device)
g_zxz_index = torch.asarray([2, 0, 2], device=device)
g_zxw_index = torch.asarray([2, 0, 3], device=device)
g_zyx_index = torch.asarray([2, 1, 0], device=device)
g_zyy_index = torch.asarray([2, 1, 1], device=device)
g_zyz_index = torch.asarray([2, 1, 2], device=device)
g_zyw_index = torch.asarray([2, 1, 3], device=device)
g_zzx_index = torch.asarray([2, 2, 0], device=device)
g_zzy_index = torch.asarray([2, 2, 1], device=device)
g_zzz_index = torch.asarray([2, 2, 2], device=device)
g_zzw_index = torch.asarray([2, 2, 3], device=device)
g_zwx_index = torch.asarray([2, 3, 0], device=device)
g_zwy_index = torch.asarray([2, 3, 1], device=device)
g_zwz_index = torch.asarray([2, 3, 2], device=device)
g_zww_index = torch.asarray([2, 3, 3], device=device)
g_wxx_index = torch.asarray([3, 0, 0], device=device)
g_wxy_index = torch.asarray([3, 0, 1], device=device)
g_wxz_index = torch.asarray([3, 0, 2], device=device)
g_wxw_index = torch.asarray([3, 0, 3], device=device)
g_wyx_index = torch.asarray([3, 1, 0], device=device)
g_wyy_index = torch.asarray([3, 1, 1], device=device)
g_wyz_index = torch.asarray([3, 1, 2], device=device)
g_wyw_index = torch.asarray([3, 1, 3], device=device)
g_wzx_index = torch.asarray([3, 2, 0], device=device)
g_wzy_index = torch.asarray([3, 2, 1], device=device)
g_wzz_index = torch.asarray([3, 2, 2], device=device)
g_wzw_index = torch.asarray([3, 2, 3], device=device)
g_wwx_index = torch.asarray([3, 3, 0], device=device)
g_wwy_index = torch.asarray([3, 3, 1], device=device)
g_wwz_index = torch.asarray([3, 3, 2], device=device)
g_www_index = torch.asarray([3, 3, 3], device=device)
g_xxxx_index = torch.asarray([0, 0, 0, 0], device=device)
g_xxxy_index = torch.asarray([0, 0, 0, 1], device=device)
g_xxxz_index = torch.asarray([0, 0, 0, 2], device=device)
g_xxxw_index = torch.asarray([0, 0, 0, 3], device=device)
g_xxyx_index = torch.asarray([0, 0, 1, 0], device=device)
g_xxyy_index = torch.asarray([0, 0, 1, 1], device=device)
g_xxyz_index = torch.asarray([0, 0, 1, 2], device=device)
g_xxyw_index = torch.asarray([0, 0, 1, 3], device=device)
g_xxzx_index = torch.asarray([0, 0, 2, 0], device=device)
g_xxzy_index = torch.asarray([0, 0, 2, 1], device=device)
g_xxzz_index = torch.asarray([0, 0, 2, 2], device=device)
g_xxzw_index = torch.asarray([0, 0, 2, 3], device=device)
g_xxwx_index = torch.asarray([0, 0, 3, 0], device=device)
g_xxwy_index = torch.asarray([0, 0, 3, 1], device=device)
g_xxwz_index = torch.asarray([0, 0, 3, 2], device=device)
g_xxww_index = torch.asarray([0, 0, 3, 3], device=device)
g_xyxx_index = torch.asarray([0, 1, 0, 0], device=device)
g_xyxy_index = torch.asarray([0, 1, 0, 1], device=device)
g_xyxz_index = torch.asarray([0, 1, 0, 2], device=device)
g_xyxw_index = torch.asarray([0, 1, 0, 3], device=device)
g_xyyx_index = torch.asarray([0, 1, 1, 0], device=device)
g_xyyy_index = torch.asarray([0, 1, 1, 1], device=device)
g_xyyz_index = torch.asarray([0, 1, 1, 2], device=device)
g_xyyw_index = torch.asarray([0, 1, 1, 3], device=device)
g_xyzx_index = torch.asarray([0, 1, 2, 0], device=device)
g_xyzy_index = torch.asarray([0, 1, 2, 1], device=device)
g_xyzz_index = torch.asarray([0, 1, 2, 2], device=device)
g_xyzw_index = torch.asarray([0, 1, 2, 3], device=device)
g_xywx_index = torch.asarray([0, 1, 3, 0], device=device)
g_xywy_index = torch.asarray([0, 1, 3, 1], device=device)
g_xywz_index = torch.asarray([0, 1, 3, 2], device=device)
g_xyww_index = torch.asarray([0, 1, 3, 3], device=device)
g_xzxx_index = torch.asarray([0, 2, 0, 0], device=device)
g_xzxy_index = torch.asarray([0, 2, 0, 1], device=device)
g_xzxz_index = torch.asarray([0, 2, 0, 2], device=device)
g_xzxw_index = torch.asarray([0, 2, 0, 3], device=device)
g_xzyx_index = torch.asarray([0, 2, 1, 0], device=device)
g_xzyy_index = torch.asarray([0, 2, 1, 1], device=device)
g_xzyz_index = torch.asarray([0, 2, 1, 2], device=device)
g_xzyw_index = torch.asarray([0, 2, 1, 3], device=device)
g_xzzx_index = torch.asarray([0, 2, 2, 0], device=device)
g_xzzy_index = torch.asarray([0, 2, 2, 1], device=device)
g_xzzz_index = torch.asarray([0, 2, 2, 2], device=device)
g_xzzw_index = torch.asarray([0, 2, 2, 3], device=device)
g_xzwx_index = torch.asarray([0, 2, 3, 0], device=device)
g_xzwy_index = torch.asarray([0, 2, 3, 1], device=device)
g_xzwz_index = torch.asarray([0, 2, 3, 2], device=device)
g_xzww_index = torch.asarray([0, 2, 3, 3], device=device)
g_xwxx_index = torch.asarray([0, 3, 0, 0], device=device)
g_xwxy_index = torch.asarray([0, 3, 0, 1], device=device)
g_xwxz_index = torch.asarray([0, 3, 0, 2], device=device)
g_xwxw_index = torch.asarray([0, 3, 0, 3], device=device)
g_xwyx_index = torch.asarray([0, 3, 1, 0], device=device)
g_xwyy_index = torch.asarray([0, 3, 1, 1], device=device)
g_xwyz_index = torch.asarray([0, 3, 1, 2], device=device)
g_xwyw_index = torch.asarray([0, 3, 1, 3], device=device)
g_xwzx_index = torch.asarray([0, 3, 2, 0], device=device)
g_xwzy_index = torch.asarray([0, 3, 2, 1], device=device)
g_xwzz_index = torch.asarray([0, 3, 2, 2], device=device)
g_xwzw_index = torch.asarray([0, 3, 2, 3], device=device)
g_xwwx_index = torch.asarray([0, 3, 3, 0], device=device)
g_xwwy_index = torch.asarray([0, 3, 3, 1], device=device)
g_xwwz_index = torch.asarray([0, 3, 3, 2], device=device)
g_xwww_index = torch.asarray([0, 3, 3, 3], device=device)
g_yxxx_index = torch.asarray([1, 0, 0, 0], device=device)
g_yxxy_index = torch.asarray([1, 0, 0, 1], device=device)
g_yxxz_index = torch.asarray([1, 0, 0, 2], device=device)
g_yxxw_index = torch.asarray([1, 0, 0, 3], device=device)
g_yxyx_index = torch.asarray([1, 0, 1, 0], device=device)
g_yxyy_index = torch.asarray([1, 0, 1, 1], device=device)
g_yxyz_index = torch.asarray([1, 0, 1, 2], device=device)
g_yxyw_index = torch.asarray([1, 0, 1, 3], device=device)
g_yxzx_index = torch.asarray([1, 0, 2, 0], device=device)
g_yxzy_index = torch.asarray([1, 0, 2, 1], device=device)
g_yxzz_index = torch.asarray([1, 0, 2, 2], device=device)
g_yxzw_index = torch.asarray([1, 0, 2, 3], device=device)
g_yxwx_index = torch.asarray([1, 0, 3, 0], device=device)
g_yxwy_index = torch.asarray([1, 0, 3, 1], device=device)
g_yxwz_index = torch.asarray([1, 0, 3, 2], device=device)
g_yxww_index = torch.asarray([1, 0, 3, 3], device=device)
g_yyxx_index = torch.asarray([1, 1, 0, 0], device=device)
g_yyxy_index = torch.asarray([1, 1, 0, 1], device=device)
g_yyxz_index = torch.asarray([1, 1, 0, 2], device=device)
g_yyxw_index = torch.asarray([1, 1, 0, 3], device=device)
g_yyyx_index = torch.asarray([1, 1, 1, 0], device=device)
g_yyyy_index = torch.asarray([1, 1, 1, 1], device=device)
g_yyyz_index = torch.asarray([1, 1, 1, 2], device=device)
g_yyyw_index = torch.asarray([1, 1, 1, 3], device=device)
g_yyzx_index = torch.asarray([1, 1, 2, 0], device=device)
g_yyzy_index = torch.asarray([1, 1, 2, 1], device=device)
g_yyzz_index = torch.asarray([1, 1, 2, 2], device=device)
g_yyzw_index = torch.asarray([1, 1, 2, 3], device=device)
g_yywx_index = torch.asarray([1, 1, 3, 0], device=device)
g_yywy_index = torch.asarray([1, 1, 3, 1], device=device)
g_yywz_index = torch.asarray([1, 1, 3, 2], device=device)
g_yyww_index = torch.asarray([1, 1, 3, 3], device=device)
g_yzxx_index = torch.asarray([1, 2, 0, 0], device=device)
g_yzxy_index = torch.asarray([1, 2, 0, 1], device=device)
g_yzxz_index = torch.asarray([1, 2, 0, 2], device=device)
g_yzxw_index = torch.asarray([1, 2, 0, 3], device=device)
g_yzyx_index = torch.asarray([1, 2, 1, 0], device=device)
g_yzyy_index = torch.asarray([1, 2, 1, 1], device=device)
g_yzyz_index = torch.asarray([1, 2, 1, 2], device=device)
g_yzyw_index = torch.asarray([1, 2, 1, 3], device=device)
g_yzzx_index = torch.asarray([1, 2, 2, 0], device=device)
g_yzzy_index = torch.asarray([1, 2, 2, 1], device=device)
g_yzzz_index = torch.asarray([1, 2, 2, 2], device=device)
g_yzzw_index = torch.asarray([1, 2, 2, 3], device=device)
g_yzwx_index = torch.asarray([1, 2, 3, 0], device=device)
g_yzwy_index = torch.asarray([1, 2, 3, 1], device=device)
g_yzwz_index = torch.asarray([1, 2, 3, 2], device=device)
g_yzww_index = torch.asarray([1, 2, 3, 3], device=device)
g_ywxx_index = torch.asarray([1, 3, 0, 0], device=device)
g_ywxy_index = torch.asarray([1, 3, 0, 1], device=device)
g_ywxz_index = torch.asarray([1, 3, 0, 2], device=device)
g_ywxw_index = torch.asarray([1, 3, 0, 3], device=device)
g_ywyx_index = torch.asarray([1, 3, 1, 0], device=device)
g_ywyy_index = torch.asarray([1, 3, 1, 1], device=device)
g_ywyz_index = torch.asarray([1, 3, 1, 2], device=device)
g_ywyw_index = torch.asarray([1, 3, 1, 3], device=device)
g_ywzx_index = torch.asarray([1, 3, 2, 0], device=device)
g_ywzy_index = torch.asarray([1, 3, 2, 1], device=device)
g_ywzz_index = torch.asarray([1, 3, 2, 2], device=device)
g_ywzw_index = torch.asarray([1, 3, 2, 3], device=device)
g_ywwx_index = torch.asarray([1, 3, 3, 0], device=device)
g_ywwy_index = torch.asarray([1, 3, 3, 1], device=device)
g_ywwz_index = torch.asarray([1, 3, 3, 2], device=device)
g_ywww_index = torch.asarray([1, 3, 3, 3], device=device)
g_zxxx_index = torch.asarray([2, 0, 0, 0], device=device)
g_zxxy_index = torch.asarray([2, 0, 0, 1], device=device)
g_zxxz_index = torch.asarray([2, 0, 0, 2], device=device)
g_zxxw_index = torch.asarray([2, 0, 0, 3], device=device)
g_zxyx_index = torch.asarray([2, 0, 1, 0], device=device)
g_zxyy_index = torch.asarray([2, 0, 1, 1], device=device)
g_zxyz_index = torch.asarray([2, 0, 1, 2], device=device)
g_zxyw_index = torch.asarray([2, 0, 1, 3], device=device)
g_zxzx_index = torch.asarray([2, 0, 2, 0], device=device)
g_zxzy_index = torch.asarray([2, 0, 2, 1], device=device)
g_zxzz_index = torch.asarray([2, 0, 2, 2], device=device)
g_zxzw_index = torch.asarray([2, 0, 2, 3], device=device)
g_zxwx_index = torch.asarray([2, 0, 3, 0], device=device)
g_zxwy_index = torch.asarray([2, 0, 3, 1], device=device)
g_zxwz_index = torch.asarray([2, 0, 3, 2], device=device)
g_zxww_index = torch.asarray([2, 0, 3, 3], device=device)
g_zyxx_index = torch.asarray([2, 1, 0, 0], device=device)
g_zyxy_index = torch.asarray([2, 1, 0, 1], device=device)
g_zyxz_index = torch.asarray([2, 1, 0, 2], device=device)
g_zyxw_index = torch.asarray([2, 1, 0, 3], device=device)
g_zyyx_index = torch.asarray([2, 1, 1, 0], device=device)
g_zyyy_index = torch.asarray([2, 1, 1, 1], device=device)
g_zyyz_index = torch.asarray([2, 1, 1, 2], device=device)
g_zyyw_index = torch.asarray([2, 1, 1, 3], device=device)
g_zyzx_index = torch.asarray([2, 1, 2, 0], device=device)
g_zyzy_index = torch.asarray([2, 1, 2, 1], device=device)
g_zyzz_index = torch.asarray([2, 1, 2, 2], device=device)
g_zyzw_index = torch.asarray([2, 1, 2, 3], device=device)
g_zywx_index = torch.asarray([2, 1, 3, 0], device=device)
g_zywy_index = torch.asarray([2, 1, 3, 1], device=device)
g_zywz_index = torch.asarray([2, 1, 3, 2], device=device)
g_zyww_index = torch.asarray([2, 1, 3, 3], device=device)
g_zzxx_index = torch.asarray([2, 2, 0, 0], device=device)
g_zzxy_index = torch.asarray([2, 2, 0, 1], device=device)
g_zzxz_index = torch.asarray([2, 2, 0, 2], device=device)
g_zzxw_index = torch.asarray([2, 2, 0, 3], device=device)
g_zzyx_index = torch.asarray([2, 2, 1, 0], device=device)
g_zzyy_index = torch.asarray([2, 2, 1, 1], device=device)
g_zzyz_index = torch.asarray([2, 2, 1, 2], device=device)
g_zzyw_index = torch.asarray([2, 2, 1, 3], device=device)
g_zzzx_index = torch.asarray([2, 2, 2, 0], device=device)
g_zzzy_index = torch.asarray([2, 2, 2, 1], device=device)
g_zzzz_index = torch.asarray([2, 2, 2, 2], device=device)
g_zzzw_index = torch.asarray([2, 2, 2, 3], device=device)
g_zzwx_index = torch.asarray([2, 2, 3, 0], device=device)
g_zzwy_index = torch.asarray([2, 2, 3, 1], device=device)
g_zzwz_index = torch.asarray([2, 2, 3, 2], device=device)
g_zzww_index = torch.asarray([2, 2, 3, 3], device=device)
g_zwxx_index = torch.asarray([2, 3, 0, 0], device=device)
g_zwxy_index = torch.asarray([2, 3, 0, 1], device=device)
g_zwxz_index = torch.asarray([2, 3, 0, 2], device=device)
g_zwxw_index = torch.asarray([2, 3, 0, 3], device=device)
g_zwyx_index = torch.asarray([2, 3, 1, 0], device=device)
g_zwyy_index = torch.asarray([2, 3, 1, 1], device=device)
g_zwyz_index = torch.asarray([2, 3, 1, 2], device=device)
g_zwyw_index = torch.asarray([2, 3, 1, 3], device=device)
g_zwzx_index = torch.asarray([2, 3, 2, 0], device=device)
g_zwzy_index = torch.asarray([2, 3, 2, 1], device=device)
g_zwzz_index = torch.asarray([2, 3, 2, 2], device=device)
g_zwzw_index = torch.asarray([2, 3, 2, 3], device=device)
g_zwwx_index = torch.asarray([2, 3, 3, 0], device=device)
g_zwwy_index = torch.asarray([2, 3, 3, 1], device=device)
g_zwwz_index = torch.asarray([2, 3, 3, 2], device=device)
g_zwww_index = torch.asarray([2, 3, 3, 3], device=device)
g_wxxx_index = torch.asarray([3, 0, 0, 0], device=device)
g_wxxy_index = torch.asarray([3, 0, 0, 1], device=device)
g_wxxz_index = torch.asarray([3, 0, 0, 2], device=device)
g_wxxw_index = torch.asarray([3, 0, 0, 3], device=device)
g_wxyx_index = torch.asarray([3, 0, 1, 0], device=device)
g_wxyy_index = torch.asarray([3, 0, 1, 1], device=device)
g_wxyz_index = torch.asarray([3, 0, 1, 2], device=device)
g_wxyw_index = torch.asarray([3, 0, 1, 3], device=device)
g_wxzx_index = torch.asarray([3, 0, 2, 0], device=device)
g_wxzy_index = torch.asarray([3, 0, 2, 1], device=device)
g_wxzz_index = torch.asarray([3, 0, 2, 2], device=device)
g_wxzw_index = torch.asarray([3, 0, 2, 3], device=device)
g_wxwx_index = torch.asarray([3, 0, 3, 0], device=device)
g_wxwy_index = torch.asarray([3, 0, 3, 1], device=device)
g_wxwz_index = torch.asarray([3, 0, 3, 2], device=device)
g_wxww_index = torch.asarray([3, 0, 3, 3], device=device)
g_wyxx_index = torch.asarray([3, 1, 0, 0], device=device)
g_wyxy_index = torch.asarray([3, 1, 0, 1], device=device)
g_wyxz_index = torch.asarray([3, 1, 0, 2], device=device)
g_wyxw_index = torch.asarray([3, 1, 0, 3], device=device)
g_wyyx_index = torch.asarray([3, 1, 1, 0], device=device)
g_wyyy_index = torch.asarray([3, 1, 1, 1], device=device)
g_wyyz_index = torch.asarray([3, 1, 1, 2], device=device)
g_wyyw_index = torch.asarray([3, 1, 1, 3], device=device)
g_wyzx_index = torch.asarray([3, 1, 2, 0], device=device)
g_wyzy_index = torch.asarray([3, 1, 2, 1], device=device)
g_wyzz_index = torch.asarray([3, 1, 2, 2], device=device)
g_wyzw_index = torch.asarray([3, 1, 2, 3], device=device)
g_wywx_index = torch.asarray([3, 1, 3, 0], device=device)
g_wywy_index = torch.asarray([3, 1, 3, 1], device=device)
g_wywz_index = torch.asarray([3, 1, 3, 2], device=device)
g_wyww_index = torch.asarray([3, 1, 3, 3], device=device)
g_wzxx_index = torch.asarray([3, 2, 0, 0], device=device)
g_wzxy_index = torch.asarray([3, 2, 0, 1], device=device)
g_wzxz_index = torch.asarray([3, 2, 0, 2], device=device)
g_wzxw_index = torch.asarray([3, 2, 0, 3], device=device)
g_wzyx_index = torch.asarray([3, 2, 1, 0], device=device)
g_wzyy_index = torch.asarray([3, 2, 1, 1], device=device)
g_wzyz_index = torch.asarray([3, 2, 1, 2], device=device)
g_wzyw_index = torch.asarray([3, 2, 1, 3], device=device)
g_wzzx_index = torch.asarray([3, 2, 2, 0], device=device)
g_wzzy_index = torch.asarray([3, 2, 2, 1], device=device)
g_wzzz_index = torch.asarray([3, 2, 2, 2], device=device)
g_wzzw_index = torch.asarray([3, 2, 2, 3], device=device)
g_wzwx_index = torch.asarray([3, 2, 3, 0], device=device)
g_wzwy_index = torch.asarray([3, 2, 3, 1], device=device)
g_wzwz_index = torch.asarray([3, 2, 3, 2], device=device)
g_wzww_index = torch.asarray([3, 2, 3, 3], device=device)
g_wwxx_index = torch.asarray([3, 3, 0, 0], device=device)
g_wwxy_index = torch.asarray([3, 3, 0, 1], device=device)
g_wwxz_index = torch.asarray([3, 3, 0, 2], device=device)
g_wwxw_index = torch.asarray([3, 3, 0, 3], device=device)
g_wwyx_index = torch.asarray([3, 3, 1, 0], device=device)
g_wwyy_index = torch.asarray([3, 3, 1, 1], device=device)
g_wwyz_index = torch.asarray([3, 3, 1, 2], device=device)
g_wwyw_index = torch.asarray([3, 3, 1, 3], device=device)
g_wwzx_index = torch.asarray([3, 3, 2, 0], device=device)
g_wwzy_index = torch.asarray([3, 3, 2, 1], device=device)
g_wwzz_index = torch.asarray([3, 3, 2, 2], device=device)
g_wwzw_index = torch.asarray([3, 3, 2, 3], device=device)
g_wwwx_index = torch.asarray([3, 3, 3, 0], device=device)
g_wwwy_index = torch.asarray([3, 3, 3, 1], device=device)
g_wwwz_index = torch.asarray([3, 3, 3, 2], device=device)
g_wwww_index = torch.asarray([3, 3, 3, 3], device=device)

def swizzle_n_x(v):
    return v
def swizzle_n_xx(v):
    return torch.asarray([v, v], device=device)
def swizzle_n_xxx(v):
    return torch.asarray([v, v, v], device=device)
def swizzle_n_xxxx(v):
    return torch.asarray([v, v, v, v], device=device)
def swizzle_n2_x(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_x_index).squeeze(0)
def swizzle_n2_y(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_y_index).squeeze(0)
def swizzle_n2_xx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xx_index)
def swizzle_n2_xy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xy_index)
def swizzle_n2_yx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yx_index)
def swizzle_n2_yy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yy_index)
def swizzle_n2_xxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxx_index)
def swizzle_n2_xxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxy_index)
def swizzle_n2_xyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyx_index)
def swizzle_n2_xyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyy_index)
def swizzle_n2_yxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxx_index)
def swizzle_n2_yxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxy_index)
def swizzle_n2_yyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyx_index)
def swizzle_n2_yyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyy_index)
def swizzle_n2_xxxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxxx_index)
def swizzle_n2_xxxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxxy_index)
def swizzle_n2_xxyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxyx_index)
def swizzle_n2_xxyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxyy_index)
def swizzle_n2_xyxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyxx_index)
def swizzle_n2_xyxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyxy_index)
def swizzle_n2_xyyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyyx_index)
def swizzle_n2_xyyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyyy_index)
def swizzle_n2_yxxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxxx_index)
def swizzle_n2_yxxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxxy_index)
def swizzle_n2_yxyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxyx_index)
def swizzle_n2_yxyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxyy_index)
def swizzle_n2_yyxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyxx_index)
def swizzle_n2_yyxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyxy_index)
def swizzle_n2_yyyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyyx_index)
def swizzle_n2_yyyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyyy_index)
def swizzle_n3_x(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_x_index).squeeze(0)
def swizzle_n3_y(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_y_index).squeeze(0)
def swizzle_n3_z(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_z_index).squeeze(0)
def swizzle_n3_xx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xx_index)
def swizzle_n3_xy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xy_index)
def swizzle_n3_xz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xz_index)
def swizzle_n3_yx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yx_index)
def swizzle_n3_yy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yy_index)
def swizzle_n3_yz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yz_index)
def swizzle_n3_zx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zx_index)
def swizzle_n3_zy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zy_index)
def swizzle_n3_zz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zz_index)
def swizzle_n3_xxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxx_index)
def swizzle_n3_xxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxy_index)
def swizzle_n3_xxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxz_index)
def swizzle_n3_xyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyx_index)
def swizzle_n3_xyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyy_index)
def swizzle_n3_xyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyz_index)
def swizzle_n3_xzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzx_index)
def swizzle_n3_xzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzy_index)
def swizzle_n3_xzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzz_index)
def swizzle_n3_yxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxx_index)
def swizzle_n3_yxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxy_index)
def swizzle_n3_yxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxz_index)
def swizzle_n3_yyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyx_index)
def swizzle_n3_yyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyy_index)
def swizzle_n3_yyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyz_index)
def swizzle_n3_yzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzx_index)
def swizzle_n3_yzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzy_index)
def swizzle_n3_yzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzz_index)
def swizzle_n3_zxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxx_index)
def swizzle_n3_zxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxy_index)
def swizzle_n3_zxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxz_index)
def swizzle_n3_zyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyx_index)
def swizzle_n3_zyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyy_index)
def swizzle_n3_zyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyz_index)
def swizzle_n3_zzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzx_index)
def swizzle_n3_zzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzy_index)
def swizzle_n3_zzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzz_index)
def swizzle_n3_xxxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxxx_index)
def swizzle_n3_xxxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxxy_index)
def swizzle_n3_xxxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxxz_index)
def swizzle_n3_xxyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxyx_index)
def swizzle_n3_xxyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxyy_index)
def swizzle_n3_xxyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxyz_index)
def swizzle_n3_xxzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxzx_index)
def swizzle_n3_xxzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxzy_index)
def swizzle_n3_xxzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxzz_index)
def swizzle_n3_xyxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyxx_index)
def swizzle_n3_xyxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyxy_index)
def swizzle_n3_xyxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyxz_index)
def swizzle_n3_xyyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyyx_index)
def swizzle_n3_xyyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyyy_index)
def swizzle_n3_xyyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyyz_index)
def swizzle_n3_xyzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyzx_index)
def swizzle_n3_xyzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyzy_index)
def swizzle_n3_xyzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyzz_index)
def swizzle_n3_xzxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzxx_index)
def swizzle_n3_xzxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzxy_index)
def swizzle_n3_xzxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzxz_index)
def swizzle_n3_xzyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzyx_index)
def swizzle_n3_xzyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzyy_index)
def swizzle_n3_xzyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzyz_index)
def swizzle_n3_xzzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzzx_index)
def swizzle_n3_xzzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzzy_index)
def swizzle_n3_xzzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzzz_index)
def swizzle_n3_yxxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxxx_index)
def swizzle_n3_yxxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxxy_index)
def swizzle_n3_yxxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxxz_index)
def swizzle_n3_yxyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxyx_index)
def swizzle_n3_yxyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxyy_index)
def swizzle_n3_yxyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxyz_index)
def swizzle_n3_yxzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxzx_index)
def swizzle_n3_yxzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxzy_index)
def swizzle_n3_yxzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxzz_index)
def swizzle_n3_yyxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyxx_index)
def swizzle_n3_yyxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyxy_index)
def swizzle_n3_yyxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyxz_index)
def swizzle_n3_yyyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyyx_index)
def swizzle_n3_yyyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyyy_index)
def swizzle_n3_yyyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyyz_index)
def swizzle_n3_yyzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyzx_index)
def swizzle_n3_yyzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyzy_index)
def swizzle_n3_yyzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyzz_index)
def swizzle_n3_yzxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzxx_index)
def swizzle_n3_yzxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzxy_index)
def swizzle_n3_yzxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzxz_index)
def swizzle_n3_yzyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzyx_index)
def swizzle_n3_yzyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzyy_index)
def swizzle_n3_yzyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzyz_index)
def swizzle_n3_yzzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzzx_index)
def swizzle_n3_yzzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzzy_index)
def swizzle_n3_yzzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzzz_index)
def swizzle_n3_zxxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxxx_index)
def swizzle_n3_zxxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxxy_index)
def swizzle_n3_zxxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxxz_index)
def swizzle_n3_zxyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxyx_index)
def swizzle_n3_zxyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxyy_index)
def swizzle_n3_zxyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxyz_index)
def swizzle_n3_zxzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxzx_index)
def swizzle_n3_zxzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxzy_index)
def swizzle_n3_zxzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxzz_index)
def swizzle_n3_zyxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyxx_index)
def swizzle_n3_zyxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyxy_index)
def swizzle_n3_zyxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyxz_index)
def swizzle_n3_zyyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyyx_index)
def swizzle_n3_zyyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyyy_index)
def swizzle_n3_zyyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyyz_index)
def swizzle_n3_zyzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyzx_index)
def swizzle_n3_zyzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyzy_index)
def swizzle_n3_zyzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyzz_index)
def swizzle_n3_zzxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzxx_index)
def swizzle_n3_zzxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzxy_index)
def swizzle_n3_zzxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzxz_index)
def swizzle_n3_zzyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzyx_index)
def swizzle_n3_zzyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzyy_index)
def swizzle_n3_zzyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzyz_index)
def swizzle_n3_zzzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzzx_index)
def swizzle_n3_zzzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzzy_index)
def swizzle_n3_zzzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzzz_index)
def swizzle_n4_x(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_x_index).squeeze(0)
def swizzle_n4_y(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_y_index).squeeze(0)
def swizzle_n4_z(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_z_index).squeeze(0)
def swizzle_n4_w(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_w_index).squeeze(0)
def swizzle_n4_xx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xx_index)
def swizzle_n4_xy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xy_index)
def swizzle_n4_xz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xz_index)
def swizzle_n4_xw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xw_index)
def swizzle_n4_yx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yx_index)
def swizzle_n4_yy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yy_index)
def swizzle_n4_yz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yz_index)
def swizzle_n4_yw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yw_index)
def swizzle_n4_zx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zx_index)
def swizzle_n4_zy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zy_index)
def swizzle_n4_zz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zz_index)
def swizzle_n4_zw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zw_index)
def swizzle_n4_wx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wx_index)
def swizzle_n4_wy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wy_index)
def swizzle_n4_wz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wz_index)
def swizzle_n4_ww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ww_index)
def swizzle_n4_xxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxx_index)
def swizzle_n4_xxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxy_index)
def swizzle_n4_xxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxz_index)
def swizzle_n4_xxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxw_index)
def swizzle_n4_xyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyx_index)
def swizzle_n4_xyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyy_index)
def swizzle_n4_xyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyz_index)
def swizzle_n4_xyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyw_index)
def swizzle_n4_xzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzx_index)
def swizzle_n4_xzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzy_index)
def swizzle_n4_xzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzz_index)
def swizzle_n4_xzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzw_index)
def swizzle_n4_xwx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwx_index)
def swizzle_n4_xwy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwy_index)
def swizzle_n4_xwz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwz_index)
def swizzle_n4_xww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xww_index)
def swizzle_n4_yxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxx_index)
def swizzle_n4_yxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxy_index)
def swizzle_n4_yxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxz_index)
def swizzle_n4_yxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxw_index)
def swizzle_n4_yyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyx_index)
def swizzle_n4_yyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyy_index)
def swizzle_n4_yyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyz_index)
def swizzle_n4_yyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyw_index)
def swizzle_n4_yzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzx_index)
def swizzle_n4_yzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzy_index)
def swizzle_n4_yzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzz_index)
def swizzle_n4_yzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzw_index)
def swizzle_n4_ywx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywx_index)
def swizzle_n4_ywy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywy_index)
def swizzle_n4_ywz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywz_index)
def swizzle_n4_yww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yww_index)
def swizzle_n4_zxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxx_index)
def swizzle_n4_zxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxy_index)
def swizzle_n4_zxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxz_index)
def swizzle_n4_zxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxw_index)
def swizzle_n4_zyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyx_index)
def swizzle_n4_zyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyy_index)
def swizzle_n4_zyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyz_index)
def swizzle_n4_zyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyw_index)
def swizzle_n4_zzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzx_index)
def swizzle_n4_zzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzy_index)
def swizzle_n4_zzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzz_index)
def swizzle_n4_zzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzw_index)
def swizzle_n4_zwx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwx_index)
def swizzle_n4_zwy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwy_index)
def swizzle_n4_zwz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwz_index)
def swizzle_n4_zww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zww_index)
def swizzle_n4_wxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxx_index)
def swizzle_n4_wxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxy_index)
def swizzle_n4_wxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxz_index)
def swizzle_n4_wxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxw_index)
def swizzle_n4_wyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyx_index)
def swizzle_n4_wyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyy_index)
def swizzle_n4_wyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyz_index)
def swizzle_n4_wyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyw_index)
def swizzle_n4_wzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzx_index)
def swizzle_n4_wzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzy_index)
def swizzle_n4_wzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzz_index)
def swizzle_n4_wzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzw_index)
def swizzle_n4_wwx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwx_index)
def swizzle_n4_wwy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwy_index)
def swizzle_n4_wwz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwz_index)
def swizzle_n4_www(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_www_index)
def swizzle_n4_xxxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxxx_index)
def swizzle_n4_xxxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxxy_index)
def swizzle_n4_xxxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxxz_index)
def swizzle_n4_xxxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxxw_index)
def swizzle_n4_xxyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxyx_index)
def swizzle_n4_xxyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxyy_index)
def swizzle_n4_xxyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxyz_index)
def swizzle_n4_xxyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxyw_index)
def swizzle_n4_xxzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxzx_index)
def swizzle_n4_xxzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxzy_index)
def swizzle_n4_xxzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxzz_index)
def swizzle_n4_xxzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxzw_index)
def swizzle_n4_xxwx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxwx_index)
def swizzle_n4_xxwy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxwy_index)
def swizzle_n4_xxwz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxwz_index)
def swizzle_n4_xxww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xxww_index)
def swizzle_n4_xyxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyxx_index)
def swizzle_n4_xyxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyxy_index)
def swizzle_n4_xyxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyxz_index)
def swizzle_n4_xyxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyxw_index)
def swizzle_n4_xyyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyyx_index)
def swizzle_n4_xyyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyyy_index)
def swizzle_n4_xyyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyyz_index)
def swizzle_n4_xyyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyyw_index)
def swizzle_n4_xyzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyzx_index)
def swizzle_n4_xyzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyzy_index)
def swizzle_n4_xyzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyzz_index)
def swizzle_n4_xyzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyzw_index)
def swizzle_n4_xywx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xywx_index)
def swizzle_n4_xywy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xywy_index)
def swizzle_n4_xywz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xywz_index)
def swizzle_n4_xyww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xyww_index)
def swizzle_n4_xzxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzxx_index)
def swizzle_n4_xzxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzxy_index)
def swizzle_n4_xzxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzxz_index)
def swizzle_n4_xzxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzxw_index)
def swizzle_n4_xzyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzyx_index)
def swizzle_n4_xzyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzyy_index)
def swizzle_n4_xzyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzyz_index)
def swizzle_n4_xzyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzyw_index)
def swizzle_n4_xzzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzzx_index)
def swizzle_n4_xzzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzzy_index)
def swizzle_n4_xzzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzzz_index)
def swizzle_n4_xzzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzzw_index)
def swizzle_n4_xzwx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzwx_index)
def swizzle_n4_xzwy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzwy_index)
def swizzle_n4_xzwz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzwz_index)
def swizzle_n4_xzww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xzww_index)
def swizzle_n4_xwxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwxx_index)
def swizzle_n4_xwxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwxy_index)
def swizzle_n4_xwxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwxz_index)
def swizzle_n4_xwxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwxw_index)
def swizzle_n4_xwyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwyx_index)
def swizzle_n4_xwyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwyy_index)
def swizzle_n4_xwyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwyz_index)
def swizzle_n4_xwyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwyw_index)
def swizzle_n4_xwzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwzx_index)
def swizzle_n4_xwzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwzy_index)
def swizzle_n4_xwzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwzz_index)
def swizzle_n4_xwzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwzw_index)
def swizzle_n4_xwwx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwwx_index)
def swizzle_n4_xwwy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwwy_index)
def swizzle_n4_xwwz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwwz_index)
def swizzle_n4_xwww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_xwww_index)
def swizzle_n4_yxxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxxx_index)
def swizzle_n4_yxxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxxy_index)
def swizzle_n4_yxxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxxz_index)
def swizzle_n4_yxxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxxw_index)
def swizzle_n4_yxyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxyx_index)
def swizzle_n4_yxyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxyy_index)
def swizzle_n4_yxyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxyz_index)
def swizzle_n4_yxyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxyw_index)
def swizzle_n4_yxzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxzx_index)
def swizzle_n4_yxzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxzy_index)
def swizzle_n4_yxzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxzz_index)
def swizzle_n4_yxzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxzw_index)
def swizzle_n4_yxwx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxwx_index)
def swizzle_n4_yxwy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxwy_index)
def swizzle_n4_yxwz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxwz_index)
def swizzle_n4_yxww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yxww_index)
def swizzle_n4_yyxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyxx_index)
def swizzle_n4_yyxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyxy_index)
def swizzle_n4_yyxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyxz_index)
def swizzle_n4_yyxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyxw_index)
def swizzle_n4_yyyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyyx_index)
def swizzle_n4_yyyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyyy_index)
def swizzle_n4_yyyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyyz_index)
def swizzle_n4_yyyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyyw_index)
def swizzle_n4_yyzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyzx_index)
def swizzle_n4_yyzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyzy_index)
def swizzle_n4_yyzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyzz_index)
def swizzle_n4_yyzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyzw_index)
def swizzle_n4_yywx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yywx_index)
def swizzle_n4_yywy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yywy_index)
def swizzle_n4_yywz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yywz_index)
def swizzle_n4_yyww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yyww_index)
def swizzle_n4_yzxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzxx_index)
def swizzle_n4_yzxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzxy_index)
def swizzle_n4_yzxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzxz_index)
def swizzle_n4_yzxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzxw_index)
def swizzle_n4_yzyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzyx_index)
def swizzle_n4_yzyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzyy_index)
def swizzle_n4_yzyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzyz_index)
def swizzle_n4_yzyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzyw_index)
def swizzle_n4_yzzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzzx_index)
def swizzle_n4_yzzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzzy_index)
def swizzle_n4_yzzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzzz_index)
def swizzle_n4_yzzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzzw_index)
def swizzle_n4_yzwx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzwx_index)
def swizzle_n4_yzwy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzwy_index)
def swizzle_n4_yzwz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzwz_index)
def swizzle_n4_yzww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_yzww_index)
def swizzle_n4_ywxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywxx_index)
def swizzle_n4_ywxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywxy_index)
def swizzle_n4_ywxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywxz_index)
def swizzle_n4_ywxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywxw_index)
def swizzle_n4_ywyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywyx_index)
def swizzle_n4_ywyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywyy_index)
def swizzle_n4_ywyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywyz_index)
def swizzle_n4_ywyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywyw_index)
def swizzle_n4_ywzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywzx_index)
def swizzle_n4_ywzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywzy_index)
def swizzle_n4_ywzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywzz_index)
def swizzle_n4_ywzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywzw_index)
def swizzle_n4_ywwx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywwx_index)
def swizzle_n4_ywwy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywwy_index)
def swizzle_n4_ywwz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywwz_index)
def swizzle_n4_ywww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_ywww_index)
def swizzle_n4_zxxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxxx_index)
def swizzle_n4_zxxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxxy_index)
def swizzle_n4_zxxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxxz_index)
def swizzle_n4_zxxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxxw_index)
def swizzle_n4_zxyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxyx_index)
def swizzle_n4_zxyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxyy_index)
def swizzle_n4_zxyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxyz_index)
def swizzle_n4_zxyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxyw_index)
def swizzle_n4_zxzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxzx_index)
def swizzle_n4_zxzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxzy_index)
def swizzle_n4_zxzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxzz_index)
def swizzle_n4_zxzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxzw_index)
def swizzle_n4_zxwx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxwx_index)
def swizzle_n4_zxwy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxwy_index)
def swizzle_n4_zxwz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxwz_index)
def swizzle_n4_zxww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zxww_index)
def swizzle_n4_zyxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyxx_index)
def swizzle_n4_zyxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyxy_index)
def swizzle_n4_zyxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyxz_index)
def swizzle_n4_zyxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyxw_index)
def swizzle_n4_zyyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyyx_index)
def swizzle_n4_zyyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyyy_index)
def swizzle_n4_zyyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyyz_index)
def swizzle_n4_zyyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyyw_index)
def swizzle_n4_zyzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyzx_index)
def swizzle_n4_zyzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyzy_index)
def swizzle_n4_zyzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyzz_index)
def swizzle_n4_zyzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyzw_index)
def swizzle_n4_zywx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zywx_index)
def swizzle_n4_zywy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zywy_index)
def swizzle_n4_zywz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zywz_index)
def swizzle_n4_zyww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zyww_index)
def swizzle_n4_zzxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzxx_index)
def swizzle_n4_zzxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzxy_index)
def swizzle_n4_zzxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzxz_index)
def swizzle_n4_zzxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzxw_index)
def swizzle_n4_zzyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzyx_index)
def swizzle_n4_zzyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzyy_index)
def swizzle_n4_zzyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzyz_index)
def swizzle_n4_zzyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzyw_index)
def swizzle_n4_zzzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzzx_index)
def swizzle_n4_zzzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzzy_index)
def swizzle_n4_zzzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzzz_index)
def swizzle_n4_zzzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzzw_index)
def swizzle_n4_zzwx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzwx_index)
def swizzle_n4_zzwy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzwy_index)
def swizzle_n4_zzwz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzwz_index)
def swizzle_n4_zzww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zzww_index)
def swizzle_n4_zwxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwxx_index)
def swizzle_n4_zwxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwxy_index)
def swizzle_n4_zwxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwxz_index)
def swizzle_n4_zwxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwxw_index)
def swizzle_n4_zwyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwyx_index)
def swizzle_n4_zwyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwyy_index)
def swizzle_n4_zwyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwyz_index)
def swizzle_n4_zwyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwyw_index)
def swizzle_n4_zwzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwzx_index)
def swizzle_n4_zwzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwzy_index)
def swizzle_n4_zwzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwzz_index)
def swizzle_n4_zwzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwzw_index)
def swizzle_n4_zwwx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwwx_index)
def swizzle_n4_zwwy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwwy_index)
def swizzle_n4_zwwz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwwz_index)
def swizzle_n4_zwww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_zwww_index)
def swizzle_n4_wxxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxxx_index)
def swizzle_n4_wxxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxxy_index)
def swizzle_n4_wxxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxxz_index)
def swizzle_n4_wxxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxxw_index)
def swizzle_n4_wxyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxyx_index)
def swizzle_n4_wxyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxyy_index)
def swizzle_n4_wxyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxyz_index)
def swizzle_n4_wxyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxyw_index)
def swizzle_n4_wxzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxzx_index)
def swizzle_n4_wxzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxzy_index)
def swizzle_n4_wxzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxzz_index)
def swizzle_n4_wxzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxzw_index)
def swizzle_n4_wxwx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxwx_index)
def swizzle_n4_wxwy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxwy_index)
def swizzle_n4_wxwz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxwz_index)
def swizzle_n4_wxww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wxww_index)
def swizzle_n4_wyxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyxx_index)
def swizzle_n4_wyxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyxy_index)
def swizzle_n4_wyxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyxz_index)
def swizzle_n4_wyxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyxw_index)
def swizzle_n4_wyyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyyx_index)
def swizzle_n4_wyyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyyy_index)
def swizzle_n4_wyyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyyz_index)
def swizzle_n4_wyyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyyw_index)
def swizzle_n4_wyzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyzx_index)
def swizzle_n4_wyzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyzy_index)
def swizzle_n4_wyzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyzz_index)
def swizzle_n4_wyzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyzw_index)
def swizzle_n4_wywx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wywx_index)
def swizzle_n4_wywy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wywy_index)
def swizzle_n4_wywz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wywz_index)
def swizzle_n4_wyww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wyww_index)
def swizzle_n4_wzxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzxx_index)
def swizzle_n4_wzxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzxy_index)
def swizzle_n4_wzxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzxz_index)
def swizzle_n4_wzxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzxw_index)
def swizzle_n4_wzyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzyx_index)
def swizzle_n4_wzyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzyy_index)
def swizzle_n4_wzyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzyz_index)
def swizzle_n4_wzyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzyw_index)
def swizzle_n4_wzzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzzx_index)
def swizzle_n4_wzzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzzy_index)
def swizzle_n4_wzzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzzz_index)
def swizzle_n4_wzzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzzw_index)
def swizzle_n4_wzwx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzwx_index)
def swizzle_n4_wzwy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzwy_index)
def swizzle_n4_wzwz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzwz_index)
def swizzle_n4_wzww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wzww_index)
def swizzle_n4_wwxx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwxx_index)
def swizzle_n4_wwxy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwxy_index)
def swizzle_n4_wwxz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwxz_index)
def swizzle_n4_wwxw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwxw_index)
def swizzle_n4_wwyx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwyx_index)
def swizzle_n4_wwyy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwyy_index)
def swizzle_n4_wwyz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwyz_index)
def swizzle_n4_wwyw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwyw_index)
def swizzle_n4_wwzx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwzx_index)
def swizzle_n4_wwzy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwzy_index)
def swizzle_n4_wwzz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwzz_index)
def swizzle_n4_wwzw(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwzw_index)
def swizzle_n4_wwwx(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwwx_index)
def swizzle_n4_wwwy(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwwy_index)
def swizzle_n4_wwwz(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwwz_index)
def swizzle_n4_wwww(v):
    v = get_vm_gpu_tensor(v)
    return v.index_select(0, g_wwww_index)
def swizzle_set_n_x(v, val):
    raise
def swizzle_set_n2_x(v, val):
    v[0] = val
    return val
def swizzle_set_n2_y(v, val):
    v[1] = val
    return val
def swizzle_set_n2_xy(v, val):
    v[0] = val[0]
    v[1] = val[1]
    return val
def swizzle_set_n2_yx(v, val):
    v[1] = val[0]
    v[0] = val[1]
    return val
def swizzle_set_n3_x(v, val):
    v[0] = val
    return val
def swizzle_set_n3_y(v, val):
    v[1] = val
    return val
def swizzle_set_n3_z(v, val):
    v[2] = val
    return val
def swizzle_set_n3_xy(v, val):
    v[0] = val[0]
    v[1] = val[1]
    return val
def swizzle_set_n3_xz(v, val):
    v[0] = val[0]
    v[2] = val[1]
    return val
def swizzle_set_n3_yx(v, val):
    v[1] = val[0]
    v[0] = val[1]
    return val
def swizzle_set_n3_yz(v, val):
    v[1] = val[0]
    v[2] = val[1]
    return val
def swizzle_set_n3_zx(v, val):
    v[2] = val[0]
    v[0] = val[1]
    return val
def swizzle_set_n3_zy(v, val):
    v[2] = val[0]
    v[1] = val[1]
    return val
def swizzle_set_n3_xyz(v, val):
    v[0] = val[0]
    v[1] = val[1]
    v[2] = val[2]
    return val
def swizzle_set_n3_xzy(v, val):
    v[0] = val[0]
    v[2] = val[1]
    v[1] = val[2]
    return val
def swizzle_set_n3_yxz(v, val):
    v[1] = val[0]
    v[0] = val[1]
    v[2] = val[2]
    return val
def swizzle_set_n3_yzx(v, val):
    v[1] = val[0]
    v[2] = val[1]
    v[0] = val[2]
    return val
def swizzle_set_n3_zxy(v, val):
    v[2] = val[0]
    v[0] = val[1]
    v[1] = val[2]
    return val
def swizzle_set_n3_zyx(v, val):
    v[2] = val[0]
    v[1] = val[1]
    v[0] = val[2]
    return val
def swizzle_set_n4_x(v, val):
    v[0] = val
    return val
def swizzle_set_n4_y(v, val):
    v[1] = val
    return val
def swizzle_set_n4_z(v, val):
    v[2] = val
    return val
def swizzle_set_n4_w(v, val):
    v[3] = val
    return val
def swizzle_set_n4_xy(v, val):
    v[0] = val[0]
    v[1] = val[1]
    return val
def swizzle_set_n4_xz(v, val):
    v[0] = val[0]
    v[2] = val[1]
    return val
def swizzle_set_n4_xw(v, val):
    v[0] = val[0]
    v[3] = val[1]
    return val
def swizzle_set_n4_yx(v, val):
    v[1] = val[0]
    v[0] = val[1]
    return val
def swizzle_set_n4_yz(v, val):
    v[1] = val[0]
    v[2] = val[1]
    return val
def swizzle_set_n4_yw(v, val):
    v[1] = val[0]
    v[3] = val[1]
    return val
def swizzle_set_n4_zx(v, val):
    v[2] = val[0]
    v[0] = val[1]
    return val
def swizzle_set_n4_zy(v, val):
    v[2] = val[0]
    v[1] = val[1]
    return val
def swizzle_set_n4_zw(v, val):
    v[2] = val[0]
    v[3] = val[1]
    return val
def swizzle_set_n4_wx(v, val):
    v[3] = val[0]
    v[0] = val[1]
    return val
def swizzle_set_n4_wy(v, val):
    v[3] = val[0]
    v[1] = val[1]
    return val
def swizzle_set_n4_wz(v, val):
    v[3] = val[0]
    v[2] = val[1]
    return val
def swizzle_set_n4_xyz(v, val):
    v[0] = val[0]
    v[1] = val[1]
    v[2] = val[2]
    return val
def swizzle_set_n4_xyw(v, val):
    v[0] = val[0]
    v[1] = val[1]
    v[3] = val[2]
    return val
def swizzle_set_n4_xzy(v, val):
    v[0] = val[0]
    v[2] = val[1]
    v[1] = val[2]
    return val
def swizzle_set_n4_xzw(v, val):
    v[0] = val[0]
    v[2] = val[1]
    v[3] = val[2]
    return val
def swizzle_set_n4_xwy(v, val):
    v[0] = val[0]
    v[3] = val[1]
    v[1] = val[2]
    return val
def swizzle_set_n4_xwz(v, val):
    v[0] = val[0]
    v[3] = val[1]
    v[2] = val[2]
    return val
def swizzle_set_n4_yxz(v, val):
    v[1] = val[0]
    v[0] = val[1]
    v[2] = val[2]
    return val
def swizzle_set_n4_yxw(v, val):
    v[1] = val[0]
    v[0] = val[1]
    v[3] = val[2]
    return val
def swizzle_set_n4_yzx(v, val):
    v[1] = val[0]
    v[2] = val[1]
    v[0] = val[2]
    return val
def swizzle_set_n4_yzw(v, val):
    v[1] = val[0]
    v[2] = val[1]
    v[3] = val[2]
    return val
def swizzle_set_n4_ywx(v, val):
    v[1] = val[0]
    v[3] = val[1]
    v[0] = val[2]
    return val
def swizzle_set_n4_ywz(v, val):
    v[1] = val[0]
    v[3] = val[1]
    v[2] = val[2]
    return val
def swizzle_set_n4_zxy(v, val):
    v[2] = val[0]
    v[0] = val[1]
    v[1] = val[2]
    return val
def swizzle_set_n4_zxw(v, val):
    v[2] = val[0]
    v[0] = val[1]
    v[3] = val[2]
    return val
def swizzle_set_n4_zyx(v, val):
    v[2] = val[0]
    v[1] = val[1]
    v[0] = val[2]
    return val
def swizzle_set_n4_zyw(v, val):
    v[2] = val[0]
    v[1] = val[1]
    v[3] = val[2]
    return val
def swizzle_set_n4_zwx(v, val):
    v[2] = val[0]
    v[3] = val[1]
    v[0] = val[2]
    return val
def swizzle_set_n4_zwy(v, val):
    v[2] = val[0]
    v[3] = val[1]
    v[1] = val[2]
    return val
def swizzle_set_n4_wxy(v, val):
    v[3] = val[0]
    v[0] = val[1]
    v[1] = val[2]
    return val
def swizzle_set_n4_wxz(v, val):
    v[3] = val[0]
    v[0] = val[1]
    v[2] = val[2]
    return val
def swizzle_set_n4_wyx(v, val):
    v[3] = val[0]
    v[1] = val[1]
    v[0] = val[2]
    return val
def swizzle_set_n4_wyz(v, val):
    v[3] = val[0]
    v[1] = val[1]
    v[2] = val[2]
    return val
def swizzle_set_n4_wzx(v, val):
    v[3] = val[0]
    v[2] = val[1]
    v[0] = val[2]
    return val
def swizzle_set_n4_wzy(v, val):
    v[3] = val[0]
    v[2] = val[1]
    v[1] = val[2]
    return val
def swizzle_set_n4_xyzw(v, val):
    v[0] = val[0]
    v[1] = val[1]
    v[2] = val[2]
    v[3] = val[3]
    return val
def swizzle_set_n4_xywz(v, val):
    v[0] = val[0]
    v[1] = val[1]
    v[3] = val[2]
    v[2] = val[3]
    return val
def swizzle_set_n4_xzyw(v, val):
    v[0] = val[0]
    v[2] = val[1]
    v[1] = val[2]
    v[3] = val[3]
    return val
def swizzle_set_n4_xzwy(v, val):
    v[0] = val[0]
    v[2] = val[1]
    v[3] = val[2]
    v[1] = val[3]
    return val
def swizzle_set_n4_xwyz(v, val):
    v[0] = val[0]
    v[3] = val[1]
    v[1] = val[2]
    v[2] = val[3]
    return val
def swizzle_set_n4_xwzy(v, val):
    v[0] = val[0]
    v[3] = val[1]
    v[2] = val[2]
    v[1] = val[3]
    return val
def swizzle_set_n4_yxzw(v, val):
    v[1] = val[0]
    v[0] = val[1]
    v[2] = val[2]
    v[3] = val[3]
    return val
def swizzle_set_n4_yxwz(v, val):
    v[1] = val[0]
    v[0] = val[1]
    v[3] = val[2]
    v[2] = val[3]
    return val
def swizzle_set_n4_yzxw(v, val):
    v[1] = val[0]
    v[2] = val[1]
    v[0] = val[2]
    v[3] = val[3]
    return val
def swizzle_set_n4_yzwx(v, val):
    v[1] = val[0]
    v[2] = val[1]
    v[3] = val[2]
    v[0] = val[3]
    return val
def swizzle_set_n4_ywxz(v, val):
    v[1] = val[0]
    v[3] = val[1]
    v[0] = val[2]
    v[2] = val[3]
    return val
def swizzle_set_n4_ywzx(v, val):
    v[1] = val[0]
    v[3] = val[1]
    v[2] = val[2]
    v[0] = val[3]
    return val
def swizzle_set_n4_zxyw(v, val):
    v[2] = val[0]
    v[0] = val[1]
    v[1] = val[2]
    v[3] = val[3]
    return val
def swizzle_set_n4_zxwy(v, val):
    v[2] = val[0]
    v[0] = val[1]
    v[3] = val[2]
    v[1] = val[3]
    return val
def swizzle_set_n4_zyxw(v, val):
    v[2] = val[0]
    v[1] = val[1]
    v[0] = val[2]
    v[3] = val[3]
    return val
def swizzle_set_n4_zywx(v, val):
    v[2] = val[0]
    v[1] = val[1]
    v[3] = val[2]
    v[0] = val[3]
    return val
def swizzle_set_n4_zwxy(v, val):
    v[2] = val[0]
    v[3] = val[1]
    v[0] = val[2]
    v[1] = val[3]
    return val
def swizzle_set_n4_zwyx(v, val):
    v[2] = val[0]
    v[3] = val[1]
    v[1] = val[2]
    v[0] = val[3]
    return val
def swizzle_set_n4_wxyz(v, val):
    v[3] = val[0]
    v[0] = val[1]
    v[1] = val[2]
    v[2] = val[3]
    return val
def swizzle_set_n4_wxzy(v, val):
    v[3] = val[0]
    v[0] = val[1]
    v[2] = val[2]
    v[1] = val[3]
    return val
def swizzle_set_n4_wyxz(v, val):
    v[3] = val[0]
    v[1] = val[1]
    v[0] = val[2]
    v[2] = val[3]
    return val
def swizzle_set_n4_wyzx(v, val):
    v[3] = val[0]
    v[1] = val[1]
    v[2] = val[2]
    v[0] = val[3]
    return val
def swizzle_set_n4_wzxy(v, val):
    v[3] = val[0]
    v[2] = val[1]
    v[0] = val[2]
    v[1] = val[3]
    return val
def swizzle_set_n4_wzyx(v, val):
    v[3] = val[0]
    v[2] = val[1]
    v[1] = val[2]
    v[0] = val[3]
    return val
def swizzle_t_n_x(v):
    return v
def swizzle_t_n_xx(v):
    return v.unsqueeze(1).index_select(1, g_xx_index)
def swizzle_t_n_xxx(v):
    return v.unsqueeze(1).index_select(1, g_xxx_index)
def swizzle_t_n_xxxx(v):
    return v.unsqueeze(1).index_select(1, g_xxxx_index)
def swizzle_t_n2_x(v):
    return torch.clone(v[..., 0])
def swizzle_t_n2_y(v):
    return torch.clone(v[..., 1])
def swizzle_t_n2_xx(v):
    return v.index_select(1, g_xx_index)
def swizzle_t_n2_xy(v):
    return v.index_select(1, g_xy_index)
def swizzle_t_n2_yx(v):
    return v.index_select(1, g_yx_index)
def swizzle_t_n2_yy(v):
    return v.index_select(1, g_yy_index)
def swizzle_t_n2_xxx(v):
    return v.index_select(1, g_xxx_index)
def swizzle_t_n2_xxy(v):
    return v.index_select(1, g_xxy_index)
def swizzle_t_n2_xyx(v):
    return v.index_select(1, g_xyx_index)
def swizzle_t_n2_xyy(v):
    return v.index_select(1, g_xyy_index)
def swizzle_t_n2_yxx(v):
    return v.index_select(1, g_yxx_index)
def swizzle_t_n2_yxy(v):
    return v.index_select(1, g_yxy_index)
def swizzle_t_n2_yyx(v):
    return v.index_select(1, g_yyx_index)
def swizzle_t_n2_yyy(v):
    return v.index_select(1, g_yyy_index)
def swizzle_t_n2_xxxx(v):
    return v.index_select(1, g_xxxx_index)
def swizzle_t_n2_xxxy(v):
    return v.index_select(1, g_xxxy_index)
def swizzle_t_n2_xxyx(v):
    return v.index_select(1, g_xxyx_index)
def swizzle_t_n2_xxyy(v):
    return v.index_select(1, g_xxyy_index)
def swizzle_t_n2_xyxx(v):
    return v.index_select(1, g_xyxx_index)
def swizzle_t_n2_xyxy(v):
    return v.index_select(1, g_xyxy_index)
def swizzle_t_n2_xyyx(v):
    return v.index_select(1, g_xyyx_index)
def swizzle_t_n2_xyyy(v):
    return v.index_select(1, g_xyyy_index)
def swizzle_t_n2_yxxx(v):
    return v.index_select(1, g_yxxx_index)
def swizzle_t_n2_yxxy(v):
    return v.index_select(1, g_yxxy_index)
def swizzle_t_n2_yxyx(v):
    return v.index_select(1, g_yxyx_index)
def swizzle_t_n2_yxyy(v):
    return v.index_select(1, g_yxyy_index)
def swizzle_t_n2_yyxx(v):
    return v.index_select(1, g_yyxx_index)
def swizzle_t_n2_yyxy(v):
    return v.index_select(1, g_yyxy_index)
def swizzle_t_n2_yyyx(v):
    return v.index_select(1, g_yyyx_index)
def swizzle_t_n2_yyyy(v):
    return v.index_select(1, g_yyyy_index)
def swizzle_t_n3_x(v):
    return torch.clone(v[..., 0])
def swizzle_t_n3_y(v):
    return torch.clone(v[..., 1])
def swizzle_t_n3_z(v):
    return torch.clone(v[..., 2])
def swizzle_t_n3_xx(v):
    return v.index_select(1, g_xx_index)
def swizzle_t_n3_xy(v):
    return v.index_select(1, g_xy_index)
def swizzle_t_n3_xz(v):
    return v.index_select(1, g_xz_index)
def swizzle_t_n3_yx(v):
    return v.index_select(1, g_yx_index)
def swizzle_t_n3_yy(v):
    return v.index_select(1, g_yy_index)
def swizzle_t_n3_yz(v):
    return v.index_select(1, g_yz_index)
def swizzle_t_n3_zx(v):
    return v.index_select(1, g_zx_index)
def swizzle_t_n3_zy(v):
    return v.index_select(1, g_zy_index)
def swizzle_t_n3_zz(v):
    return v.index_select(1, g_zz_index)
def swizzle_t_n3_xxx(v):
    return v.index_select(1, g_xxx_index)
def swizzle_t_n3_xxy(v):
    return v.index_select(1, g_xxy_index)
def swizzle_t_n3_xxz(v):
    return v.index_select(1, g_xxz_index)
def swizzle_t_n3_xyx(v):
    return v.index_select(1, g_xyx_index)
def swizzle_t_n3_xyy(v):
    return v.index_select(1, g_xyy_index)
def swizzle_t_n3_xyz(v):
    return v.index_select(1, g_xyz_index)
def swizzle_t_n3_xzx(v):
    return v.index_select(1, g_xzx_index)
def swizzle_t_n3_xzy(v):
    return v.index_select(1, g_xzy_index)
def swizzle_t_n3_xzz(v):
    return v.index_select(1, g_xzz_index)
def swizzle_t_n3_yxx(v):
    return v.index_select(1, g_yxx_index)
def swizzle_t_n3_yxy(v):
    return v.index_select(1, g_yxy_index)
def swizzle_t_n3_yxz(v):
    return v.index_select(1, g_yxz_index)
def swizzle_t_n3_yyx(v):
    return v.index_select(1, g_yyx_index)
def swizzle_t_n3_yyy(v):
    return v.index_select(1, g_yyy_index)
def swizzle_t_n3_yyz(v):
    return v.index_select(1, g_yyz_index)
def swizzle_t_n3_yzx(v):
    return v.index_select(1, g_yzx_index)
def swizzle_t_n3_yzy(v):
    return v.index_select(1, g_yzy_index)
def swizzle_t_n3_yzz(v):
    return v.index_select(1, g_yzz_index)
def swizzle_t_n3_zxx(v):
    return v.index_select(1, g_zxx_index)
def swizzle_t_n3_zxy(v):
    return v.index_select(1, g_zxy_index)
def swizzle_t_n3_zxz(v):
    return v.index_select(1, g_zxz_index)
def swizzle_t_n3_zyx(v):
    return v.index_select(1, g_zyx_index)
def swizzle_t_n3_zyy(v):
    return v.index_select(1, g_zyy_index)
def swizzle_t_n3_zyz(v):
    return v.index_select(1, g_zyz_index)
def swizzle_t_n3_zzx(v):
    return v.index_select(1, g_zzx_index)
def swizzle_t_n3_zzy(v):
    return v.index_select(1, g_zzy_index)
def swizzle_t_n3_zzz(v):
    return v.index_select(1, g_zzz_index)
def swizzle_t_n3_xxxx(v):
    return v.index_select(1, g_xxxx_index)
def swizzle_t_n3_xxxy(v):
    return v.index_select(1, g_xxxy_index)
def swizzle_t_n3_xxxz(v):
    return v.index_select(1, g_xxxz_index)
def swizzle_t_n3_xxyx(v):
    return v.index_select(1, g_xxyx_index)
def swizzle_t_n3_xxyy(v):
    return v.index_select(1, g_xxyy_index)
def swizzle_t_n3_xxyz(v):
    return v.index_select(1, g_xxyz_index)
def swizzle_t_n3_xxzx(v):
    return v.index_select(1, g_xxzx_index)
def swizzle_t_n3_xxzy(v):
    return v.index_select(1, g_xxzy_index)
def swizzle_t_n3_xxzz(v):
    return v.index_select(1, g_xxzz_index)
def swizzle_t_n3_xyxx(v):
    return v.index_select(1, g_xyxx_index)
def swizzle_t_n3_xyxy(v):
    return v.index_select(1, g_xyxy_index)
def swizzle_t_n3_xyxz(v):
    return v.index_select(1, g_xyxz_index)
def swizzle_t_n3_xyyx(v):
    return v.index_select(1, g_xyyx_index)
def swizzle_t_n3_xyyy(v):
    return v.index_select(1, g_xyyy_index)
def swizzle_t_n3_xyyz(v):
    return v.index_select(1, g_xyyz_index)
def swizzle_t_n3_xyzx(v):
    return v.index_select(1, g_xyzx_index)
def swizzle_t_n3_xyzy(v):
    return v.index_select(1, g_xyzy_index)
def swizzle_t_n3_xyzz(v):
    return v.index_select(1, g_xyzz_index)
def swizzle_t_n3_xzxx(v):
    return v.index_select(1, g_xzxx_index)
def swizzle_t_n3_xzxy(v):
    return v.index_select(1, g_xzxy_index)
def swizzle_t_n3_xzxz(v):
    return v.index_select(1, g_xzxz_index)
def swizzle_t_n3_xzyx(v):
    return v.index_select(1, g_xzyx_index)
def swizzle_t_n3_xzyy(v):
    return v.index_select(1, g_xzyy_index)
def swizzle_t_n3_xzyz(v):
    return v.index_select(1, g_xzyz_index)
def swizzle_t_n3_xzzx(v):
    return v.index_select(1, g_xzzx_index)
def swizzle_t_n3_xzzy(v):
    return v.index_select(1, g_xzzy_index)
def swizzle_t_n3_xzzz(v):
    return v.index_select(1, g_xzzz_index)
def swizzle_t_n3_yxxx(v):
    return v.index_select(1, g_yxxx_index)
def swizzle_t_n3_yxxy(v):
    return v.index_select(1, g_yxxy_index)
def swizzle_t_n3_yxxz(v):
    return v.index_select(1, g_yxxz_index)
def swizzle_t_n3_yxyx(v):
    return v.index_select(1, g_yxyx_index)
def swizzle_t_n3_yxyy(v):
    return v.index_select(1, g_yxyy_index)
def swizzle_t_n3_yxyz(v):
    return v.index_select(1, g_yxyz_index)
def swizzle_t_n3_yxzx(v):
    return v.index_select(1, g_yxzx_index)
def swizzle_t_n3_yxzy(v):
    return v.index_select(1, g_yxzy_index)
def swizzle_t_n3_yxzz(v):
    return v.index_select(1, g_yxzz_index)
def swizzle_t_n3_yyxx(v):
    return v.index_select(1, g_yyxx_index)
def swizzle_t_n3_yyxy(v):
    return v.index_select(1, g_yyxy_index)
def swizzle_t_n3_yyxz(v):
    return v.index_select(1, g_yyxz_index)
def swizzle_t_n3_yyyx(v):
    return v.index_select(1, g_yyyx_index)
def swizzle_t_n3_yyyy(v):
    return v.index_select(1, g_yyyy_index)
def swizzle_t_n3_yyyz(v):
    return v.index_select(1, g_yyyz_index)
def swizzle_t_n3_yyzx(v):
    return v.index_select(1, g_yyzx_index)
def swizzle_t_n3_yyzy(v):
    return v.index_select(1, g_yyzy_index)
def swizzle_t_n3_yyzz(v):
    return v.index_select(1, g_yyzz_index)
def swizzle_t_n3_yzxx(v):
    return v.index_select(1, g_yzxx_index)
def swizzle_t_n3_yzxy(v):
    return v.index_select(1, g_yzxy_index)
def swizzle_t_n3_yzxz(v):
    return v.index_select(1, g_yzxz_index)
def swizzle_t_n3_yzyx(v):
    return v.index_select(1, g_yzyx_index)
def swizzle_t_n3_yzyy(v):
    return v.index_select(1, g_yzyy_index)
def swizzle_t_n3_yzyz(v):
    return v.index_select(1, g_yzyz_index)
def swizzle_t_n3_yzzx(v):
    return v.index_select(1, g_yzzx_index)
def swizzle_t_n3_yzzy(v):
    return v.index_select(1, g_yzzy_index)
def swizzle_t_n3_yzzz(v):
    return v.index_select(1, g_yzzz_index)
def swizzle_t_n3_zxxx(v):
    return v.index_select(1, g_zxxx_index)
def swizzle_t_n3_zxxy(v):
    return v.index_select(1, g_zxxy_index)
def swizzle_t_n3_zxxz(v):
    return v.index_select(1, g_zxxz_index)
def swizzle_t_n3_zxyx(v):
    return v.index_select(1, g_zxyx_index)
def swizzle_t_n3_zxyy(v):
    return v.index_select(1, g_zxyy_index)
def swizzle_t_n3_zxyz(v):
    return v.index_select(1, g_zxyz_index)
def swizzle_t_n3_zxzx(v):
    return v.index_select(1, g_zxzx_index)
def swizzle_t_n3_zxzy(v):
    return v.index_select(1, g_zxzy_index)
def swizzle_t_n3_zxzz(v):
    return v.index_select(1, g_zxzz_index)
def swizzle_t_n3_zyxx(v):
    return v.index_select(1, g_zyxx_index)
def swizzle_t_n3_zyxy(v):
    return v.index_select(1, g_zyxy_index)
def swizzle_t_n3_zyxz(v):
    return v.index_select(1, g_zyxz_index)
def swizzle_t_n3_zyyx(v):
    return v.index_select(1, g_zyyx_index)
def swizzle_t_n3_zyyy(v):
    return v.index_select(1, g_zyyy_index)
def swizzle_t_n3_zyyz(v):
    return v.index_select(1, g_zyyz_index)
def swizzle_t_n3_zyzx(v):
    return v.index_select(1, g_zyzx_index)
def swizzle_t_n3_zyzy(v):
    return v.index_select(1, g_zyzy_index)
def swizzle_t_n3_zyzz(v):
    return v.index_select(1, g_zyzz_index)
def swizzle_t_n3_zzxx(v):
    return v.index_select(1, g_zzxx_index)
def swizzle_t_n3_zzxy(v):
    return v.index_select(1, g_zzxy_index)
def swizzle_t_n3_zzxz(v):
    return v.index_select(1, g_zzxz_index)
def swizzle_t_n3_zzyx(v):
    return v.index_select(1, g_zzyx_index)
def swizzle_t_n3_zzyy(v):
    return v.index_select(1, g_zzyy_index)
def swizzle_t_n3_zzyz(v):
    return v.index_select(1, g_zzyz_index)
def swizzle_t_n3_zzzx(v):
    return v.index_select(1, g_zzzx_index)
def swizzle_t_n3_zzzy(v):
    return v.index_select(1, g_zzzy_index)
def swizzle_t_n3_zzzz(v):
    return v.index_select(1, g_zzzz_index)
def swizzle_t_n4_x(v):
    return torch.clone(v[..., 0])
def swizzle_t_n4_y(v):
    return torch.clone(v[..., 1])
def swizzle_t_n4_z(v):
    return torch.clone(v[..., 2])
def swizzle_t_n4_w(v):
    return torch.clone(v[..., 3])
def swizzle_t_n4_xx(v):
    return v.index_select(1, g_xx_index)
def swizzle_t_n4_xy(v):
    return v.index_select(1, g_xy_index)
def swizzle_t_n4_xz(v):
    return v.index_select(1, g_xz_index)
def swizzle_t_n4_xw(v):
    return v.index_select(1, g_xw_index)
def swizzle_t_n4_yx(v):
    return v.index_select(1, g_yx_index)
def swizzle_t_n4_yy(v):
    return v.index_select(1, g_yy_index)
def swizzle_t_n4_yz(v):
    return v.index_select(1, g_yz_index)
def swizzle_t_n4_yw(v):
    return v.index_select(1, g_yw_index)
def swizzle_t_n4_zx(v):
    return v.index_select(1, g_zx_index)
def swizzle_t_n4_zy(v):
    return v.index_select(1, g_zy_index)
def swizzle_t_n4_zz(v):
    return v.index_select(1, g_zz_index)
def swizzle_t_n4_zw(v):
    return v.index_select(1, g_zw_index)
def swizzle_t_n4_wx(v):
    return v.index_select(1, g_wx_index)
def swizzle_t_n4_wy(v):
    return v.index_select(1, g_wy_index)
def swizzle_t_n4_wz(v):
    return v.index_select(1, g_wz_index)
def swizzle_t_n4_ww(v):
    return v.index_select(1, g_ww_index)
def swizzle_t_n4_xxx(v):
    return v.index_select(1, g_xxx_index)
def swizzle_t_n4_xxy(v):
    return v.index_select(1, g_xxy_index)
def swizzle_t_n4_xxz(v):
    return v.index_select(1, g_xxz_index)
def swizzle_t_n4_xxw(v):
    return v.index_select(1, g_xxw_index)
def swizzle_t_n4_xyx(v):
    return v.index_select(1, g_xyx_index)
def swizzle_t_n4_xyy(v):
    return v.index_select(1, g_xyy_index)
def swizzle_t_n4_xyz(v):
    return v.index_select(1, g_xyz_index)
def swizzle_t_n4_xyw(v):
    return v.index_select(1, g_xyw_index)
def swizzle_t_n4_xzx(v):
    return v.index_select(1, g_xzx_index)
def swizzle_t_n4_xzy(v):
    return v.index_select(1, g_xzy_index)
def swizzle_t_n4_xzz(v):
    return v.index_select(1, g_xzz_index)
def swizzle_t_n4_xzw(v):
    return v.index_select(1, g_xzw_index)
def swizzle_t_n4_xwx(v):
    return v.index_select(1, g_xwx_index)
def swizzle_t_n4_xwy(v):
    return v.index_select(1, g_xwy_index)
def swizzle_t_n4_xwz(v):
    return v.index_select(1, g_xwz_index)
def swizzle_t_n4_xww(v):
    return v.index_select(1, g_xww_index)
def swizzle_t_n4_yxx(v):
    return v.index_select(1, g_yxx_index)
def swizzle_t_n4_yxy(v):
    return v.index_select(1, g_yxy_index)
def swizzle_t_n4_yxz(v):
    return v.index_select(1, g_yxz_index)
def swizzle_t_n4_yxw(v):
    return v.index_select(1, g_yxw_index)
def swizzle_t_n4_yyx(v):
    return v.index_select(1, g_yyx_index)
def swizzle_t_n4_yyy(v):
    return v.index_select(1, g_yyy_index)
def swizzle_t_n4_yyz(v):
    return v.index_select(1, g_yyz_index)
def swizzle_t_n4_yyw(v):
    return v.index_select(1, g_yyw_index)
def swizzle_t_n4_yzx(v):
    return v.index_select(1, g_yzx_index)
def swizzle_t_n4_yzy(v):
    return v.index_select(1, g_yzy_index)
def swizzle_t_n4_yzz(v):
    return v.index_select(1, g_yzz_index)
def swizzle_t_n4_yzw(v):
    return v.index_select(1, g_yzw_index)
def swizzle_t_n4_ywx(v):
    return v.index_select(1, g_ywx_index)
def swizzle_t_n4_ywy(v):
    return v.index_select(1, g_ywy_index)
def swizzle_t_n4_ywz(v):
    return v.index_select(1, g_ywz_index)
def swizzle_t_n4_yww(v):
    return v.index_select(1, g_yww_index)
def swizzle_t_n4_zxx(v):
    return v.index_select(1, g_zxx_index)
def swizzle_t_n4_zxy(v):
    return v.index_select(1, g_zxy_index)
def swizzle_t_n4_zxz(v):
    return v.index_select(1, g_zxz_index)
def swizzle_t_n4_zxw(v):
    return v.index_select(1, g_zxw_index)
def swizzle_t_n4_zyx(v):
    return v.index_select(1, g_zyx_index)
def swizzle_t_n4_zyy(v):
    return v.index_select(1, g_zyy_index)
def swizzle_t_n4_zyz(v):
    return v.index_select(1, g_zyz_index)
def swizzle_t_n4_zyw(v):
    return v.index_select(1, g_zyw_index)
def swizzle_t_n4_zzx(v):
    return v.index_select(1, g_zzx_index)
def swizzle_t_n4_zzy(v):
    return v.index_select(1, g_zzy_index)
def swizzle_t_n4_zzz(v):
    return v.index_select(1, g_zzz_index)
def swizzle_t_n4_zzw(v):
    return v.index_select(1, g_zzw_index)
def swizzle_t_n4_zwx(v):
    return v.index_select(1, g_zwx_index)
def swizzle_t_n4_zwy(v):
    return v.index_select(1, g_zwy_index)
def swizzle_t_n4_zwz(v):
    return v.index_select(1, g_zwz_index)
def swizzle_t_n4_zww(v):
    return v.index_select(1, g_zww_index)
def swizzle_t_n4_wxx(v):
    return v.index_select(1, g_wxx_index)
def swizzle_t_n4_wxy(v):
    return v.index_select(1, g_wxy_index)
def swizzle_t_n4_wxz(v):
    return v.index_select(1, g_wxz_index)
def swizzle_t_n4_wxw(v):
    return v.index_select(1, g_wxw_index)
def swizzle_t_n4_wyx(v):
    return v.index_select(1, g_wyx_index)
def swizzle_t_n4_wyy(v):
    return v.index_select(1, g_wyy_index)
def swizzle_t_n4_wyz(v):
    return v.index_select(1, g_wyz_index)
def swizzle_t_n4_wyw(v):
    return v.index_select(1, g_wyw_index)
def swizzle_t_n4_wzx(v):
    return v.index_select(1, g_wzx_index)
def swizzle_t_n4_wzy(v):
    return v.index_select(1, g_wzy_index)
def swizzle_t_n4_wzz(v):
    return v.index_select(1, g_wzz_index)
def swizzle_t_n4_wzw(v):
    return v.index_select(1, g_wzw_index)
def swizzle_t_n4_wwx(v):
    return v.index_select(1, g_wwx_index)
def swizzle_t_n4_wwy(v):
    return v.index_select(1, g_wwy_index)
def swizzle_t_n4_wwz(v):
    return v.index_select(1, g_wwz_index)
def swizzle_t_n4_www(v):
    return v.index_select(1, g_www_index)
def swizzle_t_n4_xxxx(v):
    return v.index_select(1, g_xxxx_index)
def swizzle_t_n4_xxxy(v):
    return v.index_select(1, g_xxxy_index)
def swizzle_t_n4_xxxz(v):
    return v.index_select(1, g_xxxz_index)
def swizzle_t_n4_xxxw(v):
    return v.index_select(1, g_xxxw_index)
def swizzle_t_n4_xxyx(v):
    return v.index_select(1, g_xxyx_index)
def swizzle_t_n4_xxyy(v):
    return v.index_select(1, g_xxyy_index)
def swizzle_t_n4_xxyz(v):
    return v.index_select(1, g_xxyz_index)
def swizzle_t_n4_xxyw(v):
    return v.index_select(1, g_xxyw_index)
def swizzle_t_n4_xxzx(v):
    return v.index_select(1, g_xxzx_index)
def swizzle_t_n4_xxzy(v):
    return v.index_select(1, g_xxzy_index)
def swizzle_t_n4_xxzz(v):
    return v.index_select(1, g_xxzz_index)
def swizzle_t_n4_xxzw(v):
    return v.index_select(1, g_xxzw_index)
def swizzle_t_n4_xxwx(v):
    return v.index_select(1, g_xxwx_index)
def swizzle_t_n4_xxwy(v):
    return v.index_select(1, g_xxwy_index)
def swizzle_t_n4_xxwz(v):
    return v.index_select(1, g_xxwz_index)
def swizzle_t_n4_xxww(v):
    return v.index_select(1, g_xxww_index)
def swizzle_t_n4_xyxx(v):
    return v.index_select(1, g_xyxx_index)
def swizzle_t_n4_xyxy(v):
    return v.index_select(1, g_xyxy_index)
def swizzle_t_n4_xyxz(v):
    return v.index_select(1, g_xyxz_index)
def swizzle_t_n4_xyxw(v):
    return v.index_select(1, g_xyxw_index)
def swizzle_t_n4_xyyx(v):
    return v.index_select(1, g_xyyx_index)
def swizzle_t_n4_xyyy(v):
    return v.index_select(1, g_xyyy_index)
def swizzle_t_n4_xyyz(v):
    return v.index_select(1, g_xyyz_index)
def swizzle_t_n4_xyyw(v):
    return v.index_select(1, g_xyyw_index)
def swizzle_t_n4_xyzx(v):
    return v.index_select(1, g_xyzx_index)
def swizzle_t_n4_xyzy(v):
    return v.index_select(1, g_xyzy_index)
def swizzle_t_n4_xyzz(v):
    return v.index_select(1, g_xyzz_index)
def swizzle_t_n4_xyzw(v):
    return v.index_select(1, g_xyzw_index)
def swizzle_t_n4_xywx(v):
    return v.index_select(1, g_xywx_index)
def swizzle_t_n4_xywy(v):
    return v.index_select(1, g_xywy_index)
def swizzle_t_n4_xywz(v):
    return v.index_select(1, g_xywz_index)
def swizzle_t_n4_xyww(v):
    return v.index_select(1, g_xyww_index)
def swizzle_t_n4_xzxx(v):
    return v.index_select(1, g_xzxx_index)
def swizzle_t_n4_xzxy(v):
    return v.index_select(1, g_xzxy_index)
def swizzle_t_n4_xzxz(v):
    return v.index_select(1, g_xzxz_index)
def swizzle_t_n4_xzxw(v):
    return v.index_select(1, g_xzxw_index)
def swizzle_t_n4_xzyx(v):
    return v.index_select(1, g_xzyx_index)
def swizzle_t_n4_xzyy(v):
    return v.index_select(1, g_xzyy_index)
def swizzle_t_n4_xzyz(v):
    return v.index_select(1, g_xzyz_index)
def swizzle_t_n4_xzyw(v):
    return v.index_select(1, g_xzyw_index)
def swizzle_t_n4_xzzx(v):
    return v.index_select(1, g_xzzx_index)
def swizzle_t_n4_xzzy(v):
    return v.index_select(1, g_xzzy_index)
def swizzle_t_n4_xzzz(v):
    return v.index_select(1, g_xzzz_index)
def swizzle_t_n4_xzzw(v):
    return v.index_select(1, g_xzzw_index)
def swizzle_t_n4_xzwx(v):
    return v.index_select(1, g_xzwx_index)
def swizzle_t_n4_xzwy(v):
    return v.index_select(1, g_xzwy_index)
def swizzle_t_n4_xzwz(v):
    return v.index_select(1, g_xzwz_index)
def swizzle_t_n4_xzww(v):
    return v.index_select(1, g_xzww_index)
def swizzle_t_n4_xwxx(v):
    return v.index_select(1, g_xwxx_index)
def swizzle_t_n4_xwxy(v):
    return v.index_select(1, g_xwxy_index)
def swizzle_t_n4_xwxz(v):
    return v.index_select(1, g_xwxz_index)
def swizzle_t_n4_xwxw(v):
    return v.index_select(1, g_xwxw_index)
def swizzle_t_n4_xwyx(v):
    return v.index_select(1, g_xwyx_index)
def swizzle_t_n4_xwyy(v):
    return v.index_select(1, g_xwyy_index)
def swizzle_t_n4_xwyz(v):
    return v.index_select(1, g_xwyz_index)
def swizzle_t_n4_xwyw(v):
    return v.index_select(1, g_xwyw_index)
def swizzle_t_n4_xwzx(v):
    return v.index_select(1, g_xwzx_index)
def swizzle_t_n4_xwzy(v):
    return v.index_select(1, g_xwzy_index)
def swizzle_t_n4_xwzz(v):
    return v.index_select(1, g_xwzz_index)
def swizzle_t_n4_xwzw(v):
    return v.index_select(1, g_xwzw_index)
def swizzle_t_n4_xwwx(v):
    return v.index_select(1, g_xwwx_index)
def swizzle_t_n4_xwwy(v):
    return v.index_select(1, g_xwwy_index)
def swizzle_t_n4_xwwz(v):
    return v.index_select(1, g_xwwz_index)
def swizzle_t_n4_xwww(v):
    return v.index_select(1, g_xwww_index)
def swizzle_t_n4_yxxx(v):
    return v.index_select(1, g_yxxx_index)
def swizzle_t_n4_yxxy(v):
    return v.index_select(1, g_yxxy_index)
def swizzle_t_n4_yxxz(v):
    return v.index_select(1, g_yxxz_index)
def swizzle_t_n4_yxxw(v):
    return v.index_select(1, g_yxxw_index)
def swizzle_t_n4_yxyx(v):
    return v.index_select(1, g_yxyx_index)
def swizzle_t_n4_yxyy(v):
    return v.index_select(1, g_yxyy_index)
def swizzle_t_n4_yxyz(v):
    return v.index_select(1, g_yxyz_index)
def swizzle_t_n4_yxyw(v):
    return v.index_select(1, g_yxyw_index)
def swizzle_t_n4_yxzx(v):
    return v.index_select(1, g_yxzx_index)
def swizzle_t_n4_yxzy(v):
    return v.index_select(1, g_yxzy_index)
def swizzle_t_n4_yxzz(v):
    return v.index_select(1, g_yxzz_index)
def swizzle_t_n4_yxzw(v):
    return v.index_select(1, g_yxzw_index)
def swizzle_t_n4_yxwx(v):
    return v.index_select(1, g_yxwx_index)
def swizzle_t_n4_yxwy(v):
    return v.index_select(1, g_yxwy_index)
def swizzle_t_n4_yxwz(v):
    return v.index_select(1, g_yxwz_index)
def swizzle_t_n4_yxww(v):
    return v.index_select(1, g_yxww_index)
def swizzle_t_n4_yyxx(v):
    return v.index_select(1, g_yyxx_index)
def swizzle_t_n4_yyxy(v):
    return v.index_select(1, g_yyxy_index)
def swizzle_t_n4_yyxz(v):
    return v.index_select(1, g_yyxz_index)
def swizzle_t_n4_yyxw(v):
    return v.index_select(1, g_yyxw_index)
def swizzle_t_n4_yyyx(v):
    return v.index_select(1, g_yyyx_index)
def swizzle_t_n4_yyyy(v):
    return v.index_select(1, g_yyyy_index)
def swizzle_t_n4_yyyz(v):
    return v.index_select(1, g_yyyz_index)
def swizzle_t_n4_yyyw(v):
    return v.index_select(1, g_yyyw_index)
def swizzle_t_n4_yyzx(v):
    return v.index_select(1, g_yyzx_index)
def swizzle_t_n4_yyzy(v):
    return v.index_select(1, g_yyzy_index)
def swizzle_t_n4_yyzz(v):
    return v.index_select(1, g_yyzz_index)
def swizzle_t_n4_yyzw(v):
    return v.index_select(1, g_yyzw_index)
def swizzle_t_n4_yywx(v):
    return v.index_select(1, g_yywx_index)
def swizzle_t_n4_yywy(v):
    return v.index_select(1, g_yywy_index)
def swizzle_t_n4_yywz(v):
    return v.index_select(1, g_yywz_index)
def swizzle_t_n4_yyww(v):
    return v.index_select(1, g_yyww_index)
def swizzle_t_n4_yzxx(v):
    return v.index_select(1, g_yzxx_index)
def swizzle_t_n4_yzxy(v):
    return v.index_select(1, g_yzxy_index)
def swizzle_t_n4_yzxz(v):
    return v.index_select(1, g_yzxz_index)
def swizzle_t_n4_yzxw(v):
    return v.index_select(1, g_yzxw_index)
def swizzle_t_n4_yzyx(v):
    return v.index_select(1, g_yzyx_index)
def swizzle_t_n4_yzyy(v):
    return v.index_select(1, g_yzyy_index)
def swizzle_t_n4_yzyz(v):
    return v.index_select(1, g_yzyz_index)
def swizzle_t_n4_yzyw(v):
    return v.index_select(1, g_yzyw_index)
def swizzle_t_n4_yzzx(v):
    return v.index_select(1, g_yzzx_index)
def swizzle_t_n4_yzzy(v):
    return v.index_select(1, g_yzzy_index)
def swizzle_t_n4_yzzz(v):
    return v.index_select(1, g_yzzz_index)
def swizzle_t_n4_yzzw(v):
    return v.index_select(1, g_yzzw_index)
def swizzle_t_n4_yzwx(v):
    return v.index_select(1, g_yzwx_index)
def swizzle_t_n4_yzwy(v):
    return v.index_select(1, g_yzwy_index)
def swizzle_t_n4_yzwz(v):
    return v.index_select(1, g_yzwz_index)
def swizzle_t_n4_yzww(v):
    return v.index_select(1, g_yzww_index)
def swizzle_t_n4_ywxx(v):
    return v.index_select(1, g_ywxx_index)
def swizzle_t_n4_ywxy(v):
    return v.index_select(1, g_ywxy_index)
def swizzle_t_n4_ywxz(v):
    return v.index_select(1, g_ywxz_index)
def swizzle_t_n4_ywxw(v):
    return v.index_select(1, g_ywxw_index)
def swizzle_t_n4_ywyx(v):
    return v.index_select(1, g_ywyx_index)
def swizzle_t_n4_ywyy(v):
    return v.index_select(1, g_ywyy_index)
def swizzle_t_n4_ywyz(v):
    return v.index_select(1, g_ywyz_index)
def swizzle_t_n4_ywyw(v):
    return v.index_select(1, g_ywyw_index)
def swizzle_t_n4_ywzx(v):
    return v.index_select(1, g_ywzx_index)
def swizzle_t_n4_ywzy(v):
    return v.index_select(1, g_ywzy_index)
def swizzle_t_n4_ywzz(v):
    return v.index_select(1, g_ywzz_index)
def swizzle_t_n4_ywzw(v):
    return v.index_select(1, g_ywzw_index)
def swizzle_t_n4_ywwx(v):
    return v.index_select(1, g_ywwx_index)
def swizzle_t_n4_ywwy(v):
    return v.index_select(1, g_ywwy_index)
def swizzle_t_n4_ywwz(v):
    return v.index_select(1, g_ywwz_index)
def swizzle_t_n4_ywww(v):
    return v.index_select(1, g_ywww_index)
def swizzle_t_n4_zxxx(v):
    return v.index_select(1, g_zxxx_index)
def swizzle_t_n4_zxxy(v):
    return v.index_select(1, g_zxxy_index)
def swizzle_t_n4_zxxz(v):
    return v.index_select(1, g_zxxz_index)
def swizzle_t_n4_zxxw(v):
    return v.index_select(1, g_zxxw_index)
def swizzle_t_n4_zxyx(v):
    return v.index_select(1, g_zxyx_index)
def swizzle_t_n4_zxyy(v):
    return v.index_select(1, g_zxyy_index)
def swizzle_t_n4_zxyz(v):
    return v.index_select(1, g_zxyz_index)
def swizzle_t_n4_zxyw(v):
    return v.index_select(1, g_zxyw_index)
def swizzle_t_n4_zxzx(v):
    return v.index_select(1, g_zxzx_index)
def swizzle_t_n4_zxzy(v):
    return v.index_select(1, g_zxzy_index)
def swizzle_t_n4_zxzz(v):
    return v.index_select(1, g_zxzz_index)
def swizzle_t_n4_zxzw(v):
    return v.index_select(1, g_zxzw_index)
def swizzle_t_n4_zxwx(v):
    return v.index_select(1, g_zxwx_index)
def swizzle_t_n4_zxwy(v):
    return v.index_select(1, g_zxwy_index)
def swizzle_t_n4_zxwz(v):
    return v.index_select(1, g_zxwz_index)
def swizzle_t_n4_zxww(v):
    return v.index_select(1, g_zxww_index)
def swizzle_t_n4_zyxx(v):
    return v.index_select(1, g_zyxx_index)
def swizzle_t_n4_zyxy(v):
    return v.index_select(1, g_zyxy_index)
def swizzle_t_n4_zyxz(v):
    return v.index_select(1, g_zyxz_index)
def swizzle_t_n4_zyxw(v):
    return v.index_select(1, g_zyxw_index)
def swizzle_t_n4_zyyx(v):
    return v.index_select(1, g_zyyx_index)
def swizzle_t_n4_zyyy(v):
    return v.index_select(1, g_zyyy_index)
def swizzle_t_n4_zyyz(v):
    return v.index_select(1, g_zyyz_index)
def swizzle_t_n4_zyyw(v):
    return v.index_select(1, g_zyyw_index)
def swizzle_t_n4_zyzx(v):
    return v.index_select(1, g_zyzx_index)
def swizzle_t_n4_zyzy(v):
    return v.index_select(1, g_zyzy_index)
def swizzle_t_n4_zyzz(v):
    return v.index_select(1, g_zyzz_index)
def swizzle_t_n4_zyzw(v):
    return v.index_select(1, g_zyzw_index)
def swizzle_t_n4_zywx(v):
    return v.index_select(1, g_zywx_index)
def swizzle_t_n4_zywy(v):
    return v.index_select(1, g_zywy_index)
def swizzle_t_n4_zywz(v):
    return v.index_select(1, g_zywz_index)
def swizzle_t_n4_zyww(v):
    return v.index_select(1, g_zyww_index)
def swizzle_t_n4_zzxx(v):
    return v.index_select(1, g_zzxx_index)
def swizzle_t_n4_zzxy(v):
    return v.index_select(1, g_zzxy_index)
def swizzle_t_n4_zzxz(v):
    return v.index_select(1, g_zzxz_index)
def swizzle_t_n4_zzxw(v):
    return v.index_select(1, g_zzxw_index)
def swizzle_t_n4_zzyx(v):
    return v.index_select(1, g_zzyx_index)
def swizzle_t_n4_zzyy(v):
    return v.index_select(1, g_zzyy_index)
def swizzle_t_n4_zzyz(v):
    return v.index_select(1, g_zzyz_index)
def swizzle_t_n4_zzyw(v):
    return v.index_select(1, g_zzyw_index)
def swizzle_t_n4_zzzx(v):
    return v.index_select(1, g_zzzx_index)
def swizzle_t_n4_zzzy(v):
    return v.index_select(1, g_zzzy_index)
def swizzle_t_n4_zzzz(v):
    return v.index_select(1, g_zzzz_index)
def swizzle_t_n4_zzzw(v):
    return v.index_select(1, g_zzzw_index)
def swizzle_t_n4_zzwx(v):
    return v.index_select(1, g_zzwx_index)
def swizzle_t_n4_zzwy(v):
    return v.index_select(1, g_zzwy_index)
def swizzle_t_n4_zzwz(v):
    return v.index_select(1, g_zzwz_index)
def swizzle_t_n4_zzww(v):
    return v.index_select(1, g_zzww_index)
def swizzle_t_n4_zwxx(v):
    return v.index_select(1, g_zwxx_index)
def swizzle_t_n4_zwxy(v):
    return v.index_select(1, g_zwxy_index)
def swizzle_t_n4_zwxz(v):
    return v.index_select(1, g_zwxz_index)
def swizzle_t_n4_zwxw(v):
    return v.index_select(1, g_zwxw_index)
def swizzle_t_n4_zwyx(v):
    return v.index_select(1, g_zwyx_index)
def swizzle_t_n4_zwyy(v):
    return v.index_select(1, g_zwyy_index)
def swizzle_t_n4_zwyz(v):
    return v.index_select(1, g_zwyz_index)
def swizzle_t_n4_zwyw(v):
    return v.index_select(1, g_zwyw_index)
def swizzle_t_n4_zwzx(v):
    return v.index_select(1, g_zwzx_index)
def swizzle_t_n4_zwzy(v):
    return v.index_select(1, g_zwzy_index)
def swizzle_t_n4_zwzz(v):
    return v.index_select(1, g_zwzz_index)
def swizzle_t_n4_zwzw(v):
    return v.index_select(1, g_zwzw_index)
def swizzle_t_n4_zwwx(v):
    return v.index_select(1, g_zwwx_index)
def swizzle_t_n4_zwwy(v):
    return v.index_select(1, g_zwwy_index)
def swizzle_t_n4_zwwz(v):
    return v.index_select(1, g_zwwz_index)
def swizzle_t_n4_zwww(v):
    return v.index_select(1, g_zwww_index)
def swizzle_t_n4_wxxx(v):
    return v.index_select(1, g_wxxx_index)
def swizzle_t_n4_wxxy(v):
    return v.index_select(1, g_wxxy_index)
def swizzle_t_n4_wxxz(v):
    return v.index_select(1, g_wxxz_index)
def swizzle_t_n4_wxxw(v):
    return v.index_select(1, g_wxxw_index)
def swizzle_t_n4_wxyx(v):
    return v.index_select(1, g_wxyx_index)
def swizzle_t_n4_wxyy(v):
    return v.index_select(1, g_wxyy_index)
def swizzle_t_n4_wxyz(v):
    return v.index_select(1, g_wxyz_index)
def swizzle_t_n4_wxyw(v):
    return v.index_select(1, g_wxyw_index)
def swizzle_t_n4_wxzx(v):
    return v.index_select(1, g_wxzx_index)
def swizzle_t_n4_wxzy(v):
    return v.index_select(1, g_wxzy_index)
def swizzle_t_n4_wxzz(v):
    return v.index_select(1, g_wxzz_index)
def swizzle_t_n4_wxzw(v):
    return v.index_select(1, g_wxzw_index)
def swizzle_t_n4_wxwx(v):
    return v.index_select(1, g_wxwx_index)
def swizzle_t_n4_wxwy(v):
    return v.index_select(1, g_wxwy_index)
def swizzle_t_n4_wxwz(v):
    return v.index_select(1, g_wxwz_index)
def swizzle_t_n4_wxww(v):
    return v.index_select(1, g_wxww_index)
def swizzle_t_n4_wyxx(v):
    return v.index_select(1, g_wyxx_index)
def swizzle_t_n4_wyxy(v):
    return v.index_select(1, g_wyxy_index)
def swizzle_t_n4_wyxz(v):
    return v.index_select(1, g_wyxz_index)
def swizzle_t_n4_wyxw(v):
    return v.index_select(1, g_wyxw_index)
def swizzle_t_n4_wyyx(v):
    return v.index_select(1, g_wyyx_index)
def swizzle_t_n4_wyyy(v):
    return v.index_select(1, g_wyyy_index)
def swizzle_t_n4_wyyz(v):
    return v.index_select(1, g_wyyz_index)
def swizzle_t_n4_wyyw(v):
    return v.index_select(1, g_wyyw_index)
def swizzle_t_n4_wyzx(v):
    return v.index_select(1, g_wyzx_index)
def swizzle_t_n4_wyzy(v):
    return v.index_select(1, g_wyzy_index)
def swizzle_t_n4_wyzz(v):
    return v.index_select(1, g_wyzz_index)
def swizzle_t_n4_wyzw(v):
    return v.index_select(1, g_wyzw_index)
def swizzle_t_n4_wywx(v):
    return v.index_select(1, g_wywx_index)
def swizzle_t_n4_wywy(v):
    return v.index_select(1, g_wywy_index)
def swizzle_t_n4_wywz(v):
    return v.index_select(1, g_wywz_index)
def swizzle_t_n4_wyww(v):
    return v.index_select(1, g_wyww_index)
def swizzle_t_n4_wzxx(v):
    return v.index_select(1, g_wzxx_index)
def swizzle_t_n4_wzxy(v):
    return v.index_select(1, g_wzxy_index)
def swizzle_t_n4_wzxz(v):
    return v.index_select(1, g_wzxz_index)
def swizzle_t_n4_wzxw(v):
    return v.index_select(1, g_wzxw_index)
def swizzle_t_n4_wzyx(v):
    return v.index_select(1, g_wzyx_index)
def swizzle_t_n4_wzyy(v):
    return v.index_select(1, g_wzyy_index)
def swizzle_t_n4_wzyz(v):
    return v.index_select(1, g_wzyz_index)
def swizzle_t_n4_wzyw(v):
    return v.index_select(1, g_wzyw_index)
def swizzle_t_n4_wzzx(v):
    return v.index_select(1, g_wzzx_index)
def swizzle_t_n4_wzzy(v):
    return v.index_select(1, g_wzzy_index)
def swizzle_t_n4_wzzz(v):
    return v.index_select(1, g_wzzz_index)
def swizzle_t_n4_wzzw(v):
    return v.index_select(1, g_wzzw_index)
def swizzle_t_n4_wzwx(v):
    return v.index_select(1, g_wzwx_index)
def swizzle_t_n4_wzwy(v):
    return v.index_select(1, g_wzwy_index)
def swizzle_t_n4_wzwz(v):
    return v.index_select(1, g_wzwz_index)
def swizzle_t_n4_wzww(v):
    return v.index_select(1, g_wzww_index)
def swizzle_t_n4_wwxx(v):
    return v.index_select(1, g_wwxx_index)
def swizzle_t_n4_wwxy(v):
    return v.index_select(1, g_wwxy_index)
def swizzle_t_n4_wwxz(v):
    return v.index_select(1, g_wwxz_index)
def swizzle_t_n4_wwxw(v):
    return v.index_select(1, g_wwxw_index)
def swizzle_t_n4_wwyx(v):
    return v.index_select(1, g_wwyx_index)
def swizzle_t_n4_wwyy(v):
    return v.index_select(1, g_wwyy_index)
def swizzle_t_n4_wwyz(v):
    return v.index_select(1, g_wwyz_index)
def swizzle_t_n4_wwyw(v):
    return v.index_select(1, g_wwyw_index)
def swizzle_t_n4_wwzx(v):
    return v.index_select(1, g_wwzx_index)
def swizzle_t_n4_wwzy(v):
    return v.index_select(1, g_wwzy_index)
def swizzle_t_n4_wwzz(v):
    return v.index_select(1, g_wwzz_index)
def swizzle_t_n4_wwzw(v):
    return v.index_select(1, g_wwzw_index)
def swizzle_t_n4_wwwx(v):
    return v.index_select(1, g_wwwx_index)
def swizzle_t_n4_wwwy(v):
    return v.index_select(1, g_wwwy_index)
def swizzle_t_n4_wwwz(v):
    return v.index_select(1, g_wwwz_index)
def swizzle_t_n4_wwww(v):
    return v.index_select(1, g_wwww_index)
def swizzle_set_t_n_x(v, val):
    v.copy_(val)
    return val
def swizzle_set_t_n2_x(v, val):
    v[..., 0] = val
    return val
def swizzle_set_t_n2_y(v, val):
    v[..., 1] = val
    return val
def swizzle_set_t_n2_xy(v, val):
    v[..., 0] = val[..., 0]
    v[..., 1] = val[..., 1]
    return val
def swizzle_set_t_n2_yx(v, val):
    v[..., 1] = val[..., 0]
    v[..., 0] = val[..., 1]
    return val
def swizzle_set_t_n3_x(v, val):
    v[..., 0] = val
    return val
def swizzle_set_t_n3_y(v, val):
    v[..., 1] = val
    return val
def swizzle_set_t_n3_z(v, val):
    v[..., 2] = val
    return val
def swizzle_set_t_n3_xy(v, val):
    v[..., 0] = val[..., 0]
    v[..., 1] = val[..., 1]
    return val
def swizzle_set_t_n3_xz(v, val):
    v[..., 0] = val[..., 0]
    v[..., 2] = val[..., 1]
    return val
def swizzle_set_t_n3_yx(v, val):
    v[..., 1] = val[..., 0]
    v[..., 0] = val[..., 1]
    return val
def swizzle_set_t_n3_yz(v, val):
    v[..., 1] = val[..., 0]
    v[..., 2] = val[..., 1]
    return val
def swizzle_set_t_n3_zx(v, val):
    v[..., 2] = val[..., 0]
    v[..., 0] = val[..., 1]
    return val
def swizzle_set_t_n3_zy(v, val):
    v[..., 2] = val[..., 0]
    v[..., 1] = val[..., 1]
    return val
def swizzle_set_t_n3_xyz(v, val):
    v[..., 0] = val[..., 0]
    v[..., 1] = val[..., 1]
    v[..., 2] = val[..., 2]
    return val
def swizzle_set_t_n3_xzy(v, val):
    v[..., 0] = val[..., 0]
    v[..., 2] = val[..., 1]
    v[..., 1] = val[..., 2]
    return val
def swizzle_set_t_n3_yxz(v, val):
    v[..., 1] = val[..., 0]
    v[..., 0] = val[..., 1]
    v[..., 2] = val[..., 2]
    return val
def swizzle_set_t_n3_yzx(v, val):
    v[..., 1] = val[..., 0]
    v[..., 2] = val[..., 1]
    v[..., 0] = val[..., 2]
    return val
def swizzle_set_t_n3_zxy(v, val):
    v[..., 2] = val[..., 0]
    v[..., 0] = val[..., 1]
    v[..., 1] = val[..., 2]
    return val
def swizzle_set_t_n3_zyx(v, val):
    v[..., 2] = val[..., 0]
    v[..., 1] = val[..., 1]
    v[..., 0] = val[..., 2]
    return val
def swizzle_set_t_n4_x(v, val):
    v[..., 0] = val
    return val
def swizzle_set_t_n4_y(v, val):
    v[..., 1] = val
    return val
def swizzle_set_t_n4_z(v, val):
    v[..., 2] = val
    return val
def swizzle_set_t_n4_w(v, val):
    v[..., 3] = val
    return val
def swizzle_set_t_n4_xy(v, val):
    v[..., 0] = val[..., 0]
    v[..., 1] = val[..., 1]
    return val
def swizzle_set_t_n4_xz(v, val):
    v[..., 0] = val[..., 0]
    v[..., 2] = val[..., 1]
    return val
def swizzle_set_t_n4_xw(v, val):
    v[..., 0] = val[..., 0]
    v[..., 3] = val[..., 1]
    return val
def swizzle_set_t_n4_yx(v, val):
    v[..., 1] = val[..., 0]
    v[..., 0] = val[..., 1]
    return val
def swizzle_set_t_n4_yz(v, val):
    v[..., 1] = val[..., 0]
    v[..., 2] = val[..., 1]
    return val
def swizzle_set_t_n4_yw(v, val):
    v[..., 1] = val[..., 0]
    v[..., 3] = val[..., 1]
    return val
def swizzle_set_t_n4_zx(v, val):
    v[..., 2] = val[..., 0]
    v[..., 0] = val[..., 1]
    return val
def swizzle_set_t_n4_zy(v, val):
    v[..., 2] = val[..., 0]
    v[..., 1] = val[..., 1]
    return val
def swizzle_set_t_n4_zw(v, val):
    v[..., 2] = val[..., 0]
    v[..., 3] = val[..., 1]
    return val
def swizzle_set_t_n4_wx(v, val):
    v[..., 3] = val[..., 0]
    v[..., 0] = val[..., 1]
    return val
def swizzle_set_t_n4_wy(v, val):
    v[..., 3] = val[..., 0]
    v[..., 1] = val[..., 1]
    return val
def swizzle_set_t_n4_wz(v, val):
    v[..., 3] = val[..., 0]
    v[..., 2] = val[..., 1]
    return val
def swizzle_set_t_n4_xyz(v, val):
    v[..., 0] = val[..., 0]
    v[..., 1] = val[..., 1]
    v[..., 2] = val[..., 2]
    return val
def swizzle_set_t_n4_xyw(v, val):
    v[..., 0] = val[..., 0]
    v[..., 1] = val[..., 1]
    v[..., 3] = val[..., 2]
    return val
def swizzle_set_t_n4_xzy(v, val):
    v[..., 0] = val[..., 0]
    v[..., 2] = val[..., 1]
    v[..., 1] = val[..., 2]
    return val
def swizzle_set_t_n4_xzw(v, val):
    v[..., 0] = val[..., 0]
    v[..., 2] = val[..., 1]
    v[..., 3] = val[..., 2]
    return val
def swizzle_set_t_n4_xwy(v, val):
    v[..., 0] = val[..., 0]
    v[..., 3] = val[..., 1]
    v[..., 1] = val[..., 2]
    return val
def swizzle_set_t_n4_xwz(v, val):
    v[..., 0] = val[..., 0]
    v[..., 3] = val[..., 1]
    v[..., 2] = val[..., 2]
    return val
def swizzle_set_t_n4_yxz(v, val):
    v[..., 1] = val[..., 0]
    v[..., 0] = val[..., 1]
    v[..., 2] = val[..., 2]
    return val
def swizzle_set_t_n4_yxw(v, val):
    v[..., 1] = val[..., 0]
    v[..., 0] = val[..., 1]
    v[..., 3] = val[..., 2]
    return val
def swizzle_set_t_n4_yzx(v, val):
    v[..., 1] = val[..., 0]
    v[..., 2] = val[..., 1]
    v[..., 0] = val[..., 2]
    return val
def swizzle_set_t_n4_yzw(v, val):
    v[..., 1] = val[..., 0]
    v[..., 2] = val[..., 1]
    v[..., 3] = val[..., 2]
    return val
def swizzle_set_t_n4_ywx(v, val):
    v[..., 1] = val[..., 0]
    v[..., 3] = val[..., 1]
    v[..., 0] = val[..., 2]
    return val
def swizzle_set_t_n4_ywz(v, val):
    v[..., 1] = val[..., 0]
    v[..., 3] = val[..., 1]
    v[..., 2] = val[..., 2]
    return val
def swizzle_set_t_n4_zxy(v, val):
    v[..., 2] = val[..., 0]
    v[..., 0] = val[..., 1]
    v[..., 1] = val[..., 2]
    return val
def swizzle_set_t_n4_zxw(v, val):
    v[..., 2] = val[..., 0]
    v[..., 0] = val[..., 1]
    v[..., 3] = val[..., 2]
    return val
def swizzle_set_t_n4_zyx(v, val):
    v[..., 2] = val[..., 0]
    v[..., 1] = val[..., 1]
    v[..., 0] = val[..., 2]
    return val
def swizzle_set_t_n4_zyw(v, val):
    v[..., 2] = val[..., 0]
    v[..., 1] = val[..., 1]
    v[..., 3] = val[..., 2]
    return val
def swizzle_set_t_n4_zwx(v, val):
    v[..., 2] = val[..., 0]
    v[..., 3] = val[..., 1]
    v[..., 0] = val[..., 2]
    return val
def swizzle_set_t_n4_zwy(v, val):
    v[..., 2] = val[..., 0]
    v[..., 3] = val[..., 1]
    v[..., 1] = val[..., 2]
    return val
def swizzle_set_t_n4_wxy(v, val):
    v[..., 3] = val[..., 0]
    v[..., 0] = val[..., 1]
    v[..., 1] = val[..., 2]
    return val
def swizzle_set_t_n4_wxz(v, val):
    v[..., 3] = val[..., 0]
    v[..., 0] = val[..., 1]
    v[..., 2] = val[..., 2]
    return val
def swizzle_set_t_n4_wyx(v, val):
    v[..., 3] = val[..., 0]
    v[..., 1] = val[..., 1]
    v[..., 0] = val[..., 2]
    return val
def swizzle_set_t_n4_wyz(v, val):
    v[..., 3] = val[..., 0]
    v[..., 1] = val[..., 1]
    v[..., 2] = val[..., 2]
    return val
def swizzle_set_t_n4_wzx(v, val):
    v[..., 3] = val[..., 0]
    v[..., 2] = val[..., 1]
    v[..., 0] = val[..., 2]
    return val
def swizzle_set_t_n4_wzy(v, val):
    v[..., 3] = val[..., 0]
    v[..., 2] = val[..., 1]
    v[..., 1] = val[..., 2]
    return val
def swizzle_set_t_n4_xyzw(v, val):
    v[..., 0] = val[..., 0]
    v[..., 1] = val[..., 1]
    v[..., 2] = val[..., 2]
    v[..., 3] = val[..., 3]
    return val
def swizzle_set_t_n4_xywz(v, val):
    v[..., 0] = val[..., 0]
    v[..., 1] = val[..., 1]
    v[..., 3] = val[..., 2]
    v[..., 2] = val[..., 3]
    return val
def swizzle_set_t_n4_xzyw(v, val):
    v[..., 0] = val[..., 0]
    v[..., 2] = val[..., 1]
    v[..., 1] = val[..., 2]
    v[..., 3] = val[..., 3]
    return val
def swizzle_set_t_n4_xzwy(v, val):
    v[..., 0] = val[..., 0]
    v[..., 2] = val[..., 1]
    v[..., 3] = val[..., 2]
    v[..., 1] = val[..., 3]
    return val
def swizzle_set_t_n4_xwyz(v, val):
    v[..., 0] = val[..., 0]
    v[..., 3] = val[..., 1]
    v[..., 1] = val[..., 2]
    v[..., 2] = val[..., 3]
    return val
def swizzle_set_t_n4_xwzy(v, val):
    v[..., 0] = val[..., 0]
    v[..., 3] = val[..., 1]
    v[..., 2] = val[..., 2]
    v[..., 1] = val[..., 3]
    return val
def swizzle_set_t_n4_yxzw(v, val):
    v[..., 1] = val[..., 0]
    v[..., 0] = val[..., 1]
    v[..., 2] = val[..., 2]
    v[..., 3] = val[..., 3]
    return val
def swizzle_set_t_n4_yxwz(v, val):
    v[..., 1] = val[..., 0]
    v[..., 0] = val[..., 1]
    v[..., 3] = val[..., 2]
    v[..., 2] = val[..., 3]
    return val
def swizzle_set_t_n4_yzxw(v, val):
    v[..., 1] = val[..., 0]
    v[..., 2] = val[..., 1]
    v[..., 0] = val[..., 2]
    v[..., 3] = val[..., 3]
    return val
def swizzle_set_t_n4_yzwx(v, val):
    v[..., 1] = val[..., 0]
    v[..., 2] = val[..., 1]
    v[..., 3] = val[..., 2]
    v[..., 0] = val[..., 3]
    return val
def swizzle_set_t_n4_ywxz(v, val):
    v[..., 1] = val[..., 0]
    v[..., 3] = val[..., 1]
    v[..., 0] = val[..., 2]
    v[..., 2] = val[..., 3]
    return val
def swizzle_set_t_n4_ywzx(v, val):
    v[..., 1] = val[..., 0]
    v[..., 3] = val[..., 1]
    v[..., 2] = val[..., 2]
    v[..., 0] = val[..., 3]
    return val
def swizzle_set_t_n4_zxyw(v, val):
    v[..., 2] = val[..., 0]
    v[..., 0] = val[..., 1]
    v[..., 1] = val[..., 2]
    v[..., 3] = val[..., 3]
    return val
def swizzle_set_t_n4_zxwy(v, val):
    v[..., 2] = val[..., 0]
    v[..., 0] = val[..., 1]
    v[..., 3] = val[..., 2]
    v[..., 1] = val[..., 3]
    return val
def swizzle_set_t_n4_zyxw(v, val):
    v[..., 2] = val[..., 0]
    v[..., 1] = val[..., 1]
    v[..., 0] = val[..., 2]
    v[..., 3] = val[..., 3]
    return val
def swizzle_set_t_n4_zywx(v, val):
    v[..., 2] = val[..., 0]
    v[..., 1] = val[..., 1]
    v[..., 3] = val[..., 2]
    v[..., 0] = val[..., 3]
    return val
def swizzle_set_t_n4_zwxy(v, val):
    v[..., 2] = val[..., 0]
    v[..., 3] = val[..., 1]
    v[..., 0] = val[..., 2]
    v[..., 1] = val[..., 3]
    return val
def swizzle_set_t_n4_zwyx(v, val):
    v[..., 2] = val[..., 0]
    v[..., 3] = val[..., 1]
    v[..., 1] = val[..., 2]
    v[..., 0] = val[..., 3]
    return val
def swizzle_set_t_n4_wxyz(v, val):
    v[..., 3] = val[..., 0]
    v[..., 0] = val[..., 1]
    v[..., 1] = val[..., 2]
    v[..., 2] = val[..., 3]
    return val
def swizzle_set_t_n4_wxzy(v, val):
    v[..., 3] = val[..., 0]
    v[..., 0] = val[..., 1]
    v[..., 2] = val[..., 2]
    v[..., 1] = val[..., 3]
    return val
def swizzle_set_t_n4_wyxz(v, val):
    v[..., 3] = val[..., 0]
    v[..., 1] = val[..., 1]
    v[..., 0] = val[..., 2]
    v[..., 2] = val[..., 3]
    return val
def swizzle_set_t_n4_wyzx(v, val):
    v[..., 3] = val[..., 0]
    v[..., 1] = val[..., 1]
    v[..., 2] = val[..., 2]
    v[..., 0] = val[..., 3]
    return val
def swizzle_set_t_n4_wzxy(v, val):
    v[..., 3] = val[..., 0]
    v[..., 2] = val[..., 1]
    v[..., 0] = val[..., 2]
    v[..., 1] = val[..., 3]
    return val
def swizzle_set_t_n4_wzyx(v, val):
    v[..., 3] = val[..., 0]
    v[..., 2] = val[..., 1]
    v[..., 1] = val[..., 2]
    v[..., 0] = val[..., 3]
    return val
def swizzle_set_and_broadcast_n_x(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n_x(v, val), v
def swizzle_set_and_broadcast_n2_x(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n2_x(v, val), v
def swizzle_set_and_broadcast_n2_y(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n2_y(v, val), v
def swizzle_set_and_broadcast_n2_xy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n2_xy(v, val), v
def swizzle_set_and_broadcast_n2_yx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n2_yx(v, val), v
def swizzle_set_and_broadcast_n3_x(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n3_x(v, val), v
def swizzle_set_and_broadcast_n3_y(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n3_y(v, val), v
def swizzle_set_and_broadcast_n3_z(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n3_z(v, val), v
def swizzle_set_and_broadcast_n3_xy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n3_xy(v, val), v
def swizzle_set_and_broadcast_n3_xz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n3_xz(v, val), v
def swizzle_set_and_broadcast_n3_yx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n3_yx(v, val), v
def swizzle_set_and_broadcast_n3_yz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n3_yz(v, val), v
def swizzle_set_and_broadcast_n3_zx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n3_zx(v, val), v
def swizzle_set_and_broadcast_n3_zy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n3_zy(v, val), v
def swizzle_set_and_broadcast_n3_xyz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n3_xyz(v, val), v
def swizzle_set_and_broadcast_n3_xzy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n3_xzy(v, val), v
def swizzle_set_and_broadcast_n3_yxz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n3_yxz(v, val), v
def swizzle_set_and_broadcast_n3_yzx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n3_yzx(v, val), v
def swizzle_set_and_broadcast_n3_zxy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n3_zxy(v, val), v
def swizzle_set_and_broadcast_n3_zyx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n3_zyx(v, val), v
def swizzle_set_and_broadcast_n4_x(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_x(v, val), v
def swizzle_set_and_broadcast_n4_y(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_y(v, val), v
def swizzle_set_and_broadcast_n4_z(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_z(v, val), v
def swizzle_set_and_broadcast_n4_w(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_w(v, val), v
def swizzle_set_and_broadcast_n4_xy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_xy(v, val), v
def swizzle_set_and_broadcast_n4_xz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_xz(v, val), v
def swizzle_set_and_broadcast_n4_xw(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_xw(v, val), v
def swizzle_set_and_broadcast_n4_yx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_yx(v, val), v
def swizzle_set_and_broadcast_n4_yz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_yz(v, val), v
def swizzle_set_and_broadcast_n4_yw(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_yw(v, val), v
def swizzle_set_and_broadcast_n4_zx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_zx(v, val), v
def swizzle_set_and_broadcast_n4_zy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_zy(v, val), v
def swizzle_set_and_broadcast_n4_zw(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_zw(v, val), v
def swizzle_set_and_broadcast_n4_wx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_wx(v, val), v
def swizzle_set_and_broadcast_n4_wy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_wy(v, val), v
def swizzle_set_and_broadcast_n4_wz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_wz(v, val), v
def swizzle_set_and_broadcast_n4_xyz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_xyz(v, val), v
def swizzle_set_and_broadcast_n4_xyw(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_xyw(v, val), v
def swizzle_set_and_broadcast_n4_xzy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_xzy(v, val), v
def swizzle_set_and_broadcast_n4_xzw(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_xzw(v, val), v
def swizzle_set_and_broadcast_n4_xwy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_xwy(v, val), v
def swizzle_set_and_broadcast_n4_xwz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_xwz(v, val), v
def swizzle_set_and_broadcast_n4_yxz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_yxz(v, val), v
def swizzle_set_and_broadcast_n4_yxw(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_yxw(v, val), v
def swizzle_set_and_broadcast_n4_yzx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_yzx(v, val), v
def swizzle_set_and_broadcast_n4_yzw(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_yzw(v, val), v
def swizzle_set_and_broadcast_n4_ywx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_ywx(v, val), v
def swizzle_set_and_broadcast_n4_ywz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_ywz(v, val), v
def swizzle_set_and_broadcast_n4_zxy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_zxy(v, val), v
def swizzle_set_and_broadcast_n4_zxw(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_zxw(v, val), v
def swizzle_set_and_broadcast_n4_zyx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_zyx(v, val), v
def swizzle_set_and_broadcast_n4_zyw(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_zyw(v, val), v
def swizzle_set_and_broadcast_n4_zwx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_zwx(v, val), v
def swizzle_set_and_broadcast_n4_zwy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_zwy(v, val), v
def swizzle_set_and_broadcast_n4_wxy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_wxy(v, val), v
def swizzle_set_and_broadcast_n4_wxz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_wxz(v, val), v
def swizzle_set_and_broadcast_n4_wyx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_wyx(v, val), v
def swizzle_set_and_broadcast_n4_wyz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_wyz(v, val), v
def swizzle_set_and_broadcast_n4_wzx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_wzx(v, val), v
def swizzle_set_and_broadcast_n4_wzy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_wzy(v, val), v
def swizzle_set_and_broadcast_n4_xyzw(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_xyzw(v, val), v
def swizzle_set_and_broadcast_n4_xywz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_xywz(v, val), v
def swizzle_set_and_broadcast_n4_xzyw(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_xzyw(v, val), v
def swizzle_set_and_broadcast_n4_xzwy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_xzwy(v, val), v
def swizzle_set_and_broadcast_n4_xwyz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_xwyz(v, val), v
def swizzle_set_and_broadcast_n4_xwzy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_xwzy(v, val), v
def swizzle_set_and_broadcast_n4_yxzw(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_yxzw(v, val), v
def swizzle_set_and_broadcast_n4_yxwz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_yxwz(v, val), v
def swizzle_set_and_broadcast_n4_yzxw(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_yzxw(v, val), v
def swizzle_set_and_broadcast_n4_yzwx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_yzwx(v, val), v
def swizzle_set_and_broadcast_n4_ywxz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_ywxz(v, val), v
def swizzle_set_and_broadcast_n4_ywzx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_ywzx(v, val), v
def swizzle_set_and_broadcast_n4_zxyw(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_zxyw(v, val), v
def swizzle_set_and_broadcast_n4_zxwy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_zxwy(v, val), v
def swizzle_set_and_broadcast_n4_zyxw(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_zyxw(v, val), v
def swizzle_set_and_broadcast_n4_zywx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_zywx(v, val), v
def swizzle_set_and_broadcast_n4_zwxy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_zwxy(v, val), v
def swizzle_set_and_broadcast_n4_zwyx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_zwyx(v, val), v
def swizzle_set_and_broadcast_n4_wxyz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_wxyz(v, val), v
def swizzle_set_and_broadcast_n4_wxzy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_wxzy(v, val), v
def swizzle_set_and_broadcast_n4_wyxz(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_wyxz(v, val), v
def swizzle_set_and_broadcast_n4_wyzx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_wyzx(v, val), v
def swizzle_set_and_broadcast_n4_wzxy(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_wzxy(v, val), v
def swizzle_set_and_broadcast_n4_wzyx(v, val):
    v = torch.tile(v, (len(val), 1))
    return swizzle_set_t_n4_wzyx(v, val), v
#---end---
#----------------------------------------


#pip install matplotlib numpy pyjion imageio PyOpenGL glfw
#conda install pytorch torchvision torchaudio pytorch-cuda=11.7 -c pytorch -c nvidia

import matplotlib.pyplot as plt
import matplotlib.animation as mpanim
import imageio.v3 as iio
import OpenGL.GL as gl
import glfw
import nvdiffrast.torch as dr
import time
import functools
import cProfile
import pstats
import io
import os
from pstats import SortKey

def any_ifexp_true_n(v):
    return v
def not_all_ifexp_true_n(v):
    return not v
def not_any_ifexp_true_n(v):
    return not v
def any_ifexp_true_t_n(v):
    return torch.any(v)
def not_all_ifexp_true_t_n(v):
    return not torch.all(v)
def not_any_ifexp_true_t_n(v):
    return not torch.any(v)

def array_copy(v):
    return torch.clone(v)

def init_buffer():
    global iResolution
    return torch.broadcast_to(torch.asarray([[0.0, 0.0, 0.0, 1.0]], device=device), (iResolution[0] * iResolution[1], 4))
def buffer_to_tex(v):
    global iResolution
    img = torch.stack(torch.tensor_split(v, iResolution[1]))
    img = img.cpu().numpy()
    img = img[::-1, :, :] # Flip vertically.
    img = np.clip(np.rint(img * 255), 0, 255).astype(np.uint8) # Quantize to np.uint8
    data = np.flip(np.transpose(img, (1, 0, 2)), 1)
    return torch.from_numpy(data.copy()).float().cuda()

def load_tex_2d(file):
    data = iio.imread(file)
    if len(data.shape) == 2:
        data = np.flip(np.transpose(data), 1)
    else:
        data = np.flip(np.transpose(data, (1, 0, 2)), 1)
    #return torch.as_tensor(data.astype(np.float64), device=device, requires_grad=True)
    return torch.from_numpy(data.copy()).float().cuda()

def load_tex_cube(file):
    nameAndExts = os.path.splitext(file)
    data = iio.imread(file)
    data1 = iio.imread(nameAndExts[0]+"_1"+nameAndExts[1])
    data2 = iio.imread(nameAndExts[0]+"_2"+nameAndExts[1])
    data3 = iio.imread(nameAndExts[0]+"_3"+nameAndExts[1])
    data4 = iio.imread(nameAndExts[0]+"_4"+nameAndExts[1])
    data5 = iio.imread(nameAndExts[0]+"_5"+nameAndExts[1])
    datas = [data, data1, data2, data3, data4, data5]
    for i in range(5):
        d = datas[i]
        if len(data.shape) == 2:
            d = np.flip(np.transpose(d), 1)
        else:
            d = np.flip(np.transpose(d, (1, 0, 2)), 1)
        datas[i] = d
    ds = np.moveaxis(np.stack(datas), 0, 2)
    return torch.from_numpy(ds.copy()).float().cuda()

def load_tex_3d(file):
    f = open(file, "rb")
    head = np.fromfile(f, dtype=np.uint32, count=5, offset=0)
    tag = head[0]
    w = head[1]
    h = head[2]
    d = head[3]
    data = np.fromfile(f, dtype=np.uint8, count=-1, offset=0)
    f.close()
    data = data.reshape(w, h, d)
    return torch.from_numpy(data.copy()).float().cuda()
    '''
    data = iio.imread(file)
    if len(data.shape) == 2:
        return np.flip(np.transpose(data), 1)
    else:
        return np.flip(np.transpose(data, (1, 0, 2)), 1)
    '''

def set_channel_resolution(ix, buf):
    global iChannelResolution
    if buf is not None:
        shape = buf.shape
        n = len(shape)
        for i in range(3):
            if i < n:
                iChannelResolution[ix][i] = shape[i] 

def mouse_button_callback(window, button, action, mods):
    global iMouse, iResolution
    x_pos, y_pos = glfw.get_cursor_pos(window)
    y_pos = iResolution[1] - y_pos
    if button == glfw.MOUSE_BUTTON_RIGHT and action == glfw.PRESS:
        pass
    if button == glfw.MOUSE_BUTTON_LEFT and action == glfw.PRESS:
        print("mouse {0} press, ({1}, {2})".format(str(button), x_pos, y_pos))
        iMouse[0] = x_pos
        iMouse[1] = y_pos
        iMouse[2] = x_pos
        iMouse[3] = y_pos

def cursor_pos_callback(window, x_pos, y_pos):
    if glfw.get_mouse_button(window, glfw.MOUSE_BUTTON_RIGHT) == glfw.PRESS:
        print("mouse move, ({0}, {1})".format(x_pos, y_pos))
        iMouse[0] = x_pos
        iMouse[1] = y_pos
    elif glfw.get_mouse_button(window, glfw.MOUSE_BUTTON_LEFT) == glfw.PRESS:
        pass

def scroll_callback(window, x_offset, y_offset):
    x_pos, y_pos = glfw.get_cursor_pos(window)
    pass

def key_callback(window, key, scancode, action, mods):
    if action==glfw.PRESS:
        pass
    elif action==glfw.RELEASE:
        pass

def display_image(image, zoom=None, size=None, title=None): # HWC

    # Zoom image if requested.
    image = np.asarray(image)

    if size is not None:
        assert zoom is None
        zoom = max(1, size // image.shape[0])
    if zoom is not None:
        image = image.repeat(zoom, axis=0).repeat(zoom, axis=1)
    height, width, channels = image.shape

    # Initialize window.
    if title is None:
        title = 'Debug window'
    global g_glfw_window
    if g_glfw_window is None:
        glfw.init()
        g_glfw_window = glfw.create_window(width, height, title, None, None)
        glfw.make_context_current(g_glfw_window)
        glfw.show_window(g_glfw_window)
        glfw.swap_interval(0)
        glfw.set_mouse_button_callback(g_glfw_window, mouse_button_callback)
        glfw.set_cursor_pos_callback(g_glfw_window, cursor_pos_callback)
        glfw.set_scroll_callback(g_glfw_window, scroll_callback)
        glfw.set_key_callback(g_glfw_window, key_callback)
    else:
        glfw.make_context_current(g_glfw_window)
        glfw.set_window_title(g_glfw_window, title)
        glfw.set_window_size(g_glfw_window, width, height)

    # Update window.
    glfw.poll_events()
    gl.glClearColor(0, 0, 0, 1)
    gl.glClear(gl.GL_COLOR_BUFFER_BIT)
    gl.glWindowPos2f(0, 0)
    gl.glPixelStorei(gl.GL_UNPACK_ALIGNMENT, 1)
    gl_format = {4: gl.GL_RGBA, 3: gl.GL_RGB, 2: gl.GL_RG, 1: gl.GL_LUMINANCE}[channels]
    gl_dtype = {'uint8': gl.GL_UNSIGNED_BYTE, 'float32': gl.GL_FLOAT}[image.dtype.name]
    gl.glDrawPixels(width, height, gl_format, gl_dtype, image[::-1])
    glfw.swap_buffers(g_glfw_window)
    if glfw.window_should_close(g_glfw_window):
        return False
    return True

def save_image(fn, x):
    x = torch.rint(x * 255.0)
    x = torch.clip(x, 0, 255).astype(torch.uint8)
    iio.imsave(fn, x)

def update(frame, ax, fc, fcd):
    global iTime, iTimeDelta, iFrame, iFrameRate, iResolution, g_last_time
    curTime = time.time()
    iTimeDelta = curTime - g_last_time
    g_last_time = curTime
    iTime += iTimeDelta
    iFrame += 1
    if iTimeDelta > 0.01:
        iFrameRate = iFrameRate * 0.7 + 0.3 / iTimeDelta
    
    V = shader_main(fc, fcd)
    maxv = abs(V).max()
    minv = -abs(V).max()
    V = torch.stack(torch.tensor_split(V, iResolution[1]))
    V = get_cpu_value(V)
    ax.clear()
    cameraz = 0.0
    if hasattr(sys.modules[__name__], "get_camera_z"):
        cameraz = get_camera_z()
    elif hasattr(sys.modules[__name__], "get_camera_pos"):
        cameraz = get_camera_pos()[2]
    else:
        cameraz = 0.0
    info = "time:{0:.3f} frame time:{1:.3f} camera z:{2:.2f}".format(iTime, iTimeDelta, cameraz)
    fig = plt.gcf()
    fig.canvas.manager.set_window_title(info)
    ax.text(0.0, 1.0, info)
    im = ax.imshow(V, interpolation='bilinear',
                   origin='lower', extent=[0, iResolution[0], 0, iResolution[1]],
                   vmax=maxv, vmin=-minv)
    tensor_pools.RecycleAll()

def on_press(event):
    global iMouse
    print("mouse {0} press, ({1}, {2})".format(str(event.button), event.xdata, event.ydata))
    iMouse[0] = event.xdata
    iMouse[1] = event.ydata
    iMouse[2] = event.xdata
    iMouse[3] = event.ydata
    
def on_release(event):
    print(str(event.button)+" release.")

def on_motion(event):
    if event.button == 1:
        print("mouse move: {0} {1} - {2} {3} button:{4}".format(event.x, event.y, event.xdata, event.ydata, event.button))
        iMouse[0] = event.xdata
        iMouse[1] = event.ydata
    elif event.button == 2:
        pass
    elif event.button == 3:
        pass

def on_scroll(event):
    #print("mouse scroll: {0}".format(event.step))
    pass

def on_key_press(event):
    print(event.key+" press.")

def on_key_release(event):
    print(event.key+" release.")

def main_entry():
    global iTime, iTimeDelta, iFrame, iFrameRate, iResolution, g_last_time, g_show_with_opengl, g_is_profiling, g_face_color, g_win_zoom, g_win_size
    torch.manual_seed(19680801)
    iTimeDelta = 0
    iTime = 0
    iFrame = 0
    
    coordx = torch.arange(0.0, iResolution[0])
    coordy = torch.arange(0.0, iResolution[1])
    X, Y = torch.meshgrid(coordx, coordy, indexing="xy")
    X = torch.reshape(X, (-1, ))
    Y = torch.reshape(Y, (-1, ))
    
    fcd = torch.column_stack((X, Y))
    fc = torch.tile(h_f4_n_n_n_n(0.5, 0.5, 0.5, 1.0), (iResolution[0] * iResolution[1], 1))
    #fc = torch.as_tensor([0.5,0.5,0.5,1.0], device=device)

    fcd = fcd.cuda()
    fc = fc.cuda()

    print(fcd.is_cuda, fc.is_cuda)

    if g_show_with_opengl:
        g_last_time = time.time()
        iterCount = 10 if g_is_profiling else 1000
        for ct in range(iterCount):
            curTime = time.time()
            iTimeDelta = curTime - g_last_time
            iTime += iTimeDelta
            iFrame += 1
            if iTimeDelta > 0.01:
                iFrameRate = iFrameRate * 0.7 + 0.3 / iTimeDelta
            g_last_time = curTime

            V = shader_main(fc, fcd)

            img = torch.stack(torch.tensor_split(V, iResolution[1]))
            img = img.cpu().numpy()
            img = img[::-1, :, :] # Flip vertically.
            img = np.clip(np.rint(img * 255), 0, 255).astype(np.uint8) # Quantize to np.uint8
            wtitle = "time:{0:.3f} frame time:{1:.3f} iter:{2}".format(iTime, iTimeDelta, ct)
            display_image(img, g_win_zoom, g_win_size, wtitle)
            tensor_pools.RecycleAll()
            time.sleep(0.033)
    else:
        fig, ax = plt.subplots()
        ax.set_facecolor(g_face_color)
        cidpress = fig.canvas.mpl_connect('button_press_event', on_press)
        cidrelease = fig.canvas.mpl_connect('button_release_event', on_release)
        cidmotion = fig.canvas.mpl_connect('motion_notify_event', on_motion)
        cidscroll = fig.canvas.mpl_connect('scroll_event', on_scroll)
        kpid = fig.canvas.mpl_connect('key_press_event', on_key_press)
        krid = fig.canvas.mpl_connect('key_release_event', on_key_release)
        g_last_time = time.time()
        ani = mpanim.FuncAnimation(fig, functools.partial(update, ax = ax, fc = fc, fcd = fcd), interval = 100.0, repeat = not g_is_profiling)
        plt.show()
        #plt.pause(0.1)

class MyProfiler:
    def __init__(self) -> None:
        self.datas = {}
    def beginSample(self, tag):
        data = self.datas.get(tag)
        if data is None:
            data = [0, 0.0, 0.0]
            self.datas[tag] = data
        data[0] += 1
        data[1] = time.time()
    def endSample(self, tag, is_show=True):
        data = self.datas.get(tag)
        if data is not None:
            data[1] = time.time() - data[1]
            data[2] += data[1]
            if is_show:
                print("{0} ct:{1} time:{2} total:{3} avg:{4}".format(tag, data[0], data[1], data[2], data[2]/data[0]))
    def ShowTotal(self):
        print("[total:]")
        for tag, data in self.datas.items():
            print("{0} ct:{1} total:{2} avg:{3}".format(tag, data[0], data[2], data[2]/data[0]))

def profile_entry(real_entry):
    pr = cProfile.Profile()
    pr.enable()
    real_entry()
    pr.disable()
    s = io.StringIO()
    sortby = SortKey.CUMULATIVE #SortKey.TIME
    ps = pstats.Stats(pr, stream=s).sort_stats(sortby)
    ps.print_stats()
    print(s.getvalue())

def main_entry_autodiff():
    global iTime, iTimeDelta, iFrame, iFrameRate, iResolution, g_last_time, g_target_img, g_show_with_opengl, g_is_profiling, g_face_color, g_win_zoom, g_win_size
    torch.manual_seed(19680801)
    iTimeDelta = 0
    iTime = 0
    iFrame = 0

    coordx = torch.arange(0.0, iResolution[0])
    coordy = torch.arange(0.0, iResolution[1])
    X, Y = torch.meshgrid(coordx, coordy, indexing="xy")
    X = torch.reshape(X, (-1, ))
    Y = torch.reshape(Y, (-1, ))

    g_target_img = iio.imread("target.jpg")
    g_target_img = torch.from_numpy(g_target_img).float()
    g_target_img = get_gpu_value(g_target_img)

    target = torch.flatten(g_target_img)[0:(iResolution[0]*iResolution[1])]
    optimizer = torch.optim.SGD(params=[iChannel2], lr = 10000.1)
    scheduler = torch.optim.lr_scheduler.ExponentialLR(optimizer, gamma=0.5)
    loss_f = torch.nn.L1Loss()

    fcd = torch.column_stack((X, Y))
    fc = torch.broadcast_to(get_vm_gpu_tensor([0.5, 0.5, 0.5, 1.0]), (iResolution[0] * iResolution[1], 4))
    #fc = torch.as_tensor([0.5, 0.5, 0.5, 1.0], device=device)

    fcd = fcd.cuda()
    fc = fc.cuda()

    print(fcd.is_cuda, fc.is_cuda)

    if g_show_with_opengl:
        g_last_time = time.time()
        epoch = 10
        iterCount = 1 if g_is_profiling else 1000
        for st in range(epoch):
            for ct in range(iterCount):
                curTime = time.time()
                #iTime += curTime - g_last_time
                g_last_time = curTime

                optimizer.zero_grad()
                V = shader_main(fc, fcd)
                vs = V[..., 0] * 255.0
                loss = loss_f(vs, target)
                loss.backward()
                optimizer.step()

                img = torch.stack(torch.tensor_split(V, iResolution[1]))
                img = img.cpu().detach().numpy()
                img = img[::-1, :, :] # Flip vertically.
                img = np.clip(np.rint(img * 255), 0, 255).astype(np.uint8) # Quantize to np.uint8

                info = "epoch:" + str(st) + "iter:" + str(ct) + " grad:" + str(loss)
                print(info)
                display_image(img, g_win_zoom, g_win_size, info)
                tensor_pools.RecycleAll()
                time.sleep(0.033)
            scheduler.step()

        iio.imsave("autogen.jpg", iChannel2.cpu().detach().numpy())
    else:
        fig, ax = plt.subplots()
        g_last_time = time.time()
        ani = mpanim.FuncAnimation(fig, functools.partial(update, ax = ax, fc = fc, fcd = fcd), interval = 100.0, repeat = not g_is_profiling)
        plt.show()
        #plt.pause(0.1)

_ = None

g_last_time = 0.0
g_target_img = None
g_glfw_window = None
g_show_with_opengl = False
g_is_profiling = False
g_is_autodiff = False
g_is_full_vectorized = False

g_main_iChannel0 = None
g_main_iChannel1 = None
g_main_iChannel2 = None
g_main_iChannel3 = None

g_bufferA_iChannel0 = None
g_bufferA_iChannel1 = None
g_bufferA_iChannel2 = None
g_bufferA_iChannel3 = None

g_bufferB_iChannel0 = None
g_bufferB_iChannel1 = None
g_bufferB_iChannel2 = None
g_bufferB_iChannel3 = None

g_bufferC_iChannel0 = None
g_bufferC_iChannel1 = None
g_bufferC_iChannel2 = None
g_bufferC_iChannel3 = None

g_bufferD_iChannel0 = None
g_bufferD_iChannel1 = None
g_bufferD_iChannel2 = None
g_bufferD_iChannel3 = None

g_bufferCubemap_iChannel0 = None
g_bufferCubemap_iChannel1 = None
g_bufferCubemap_iChannel2 = None
g_bufferCubemap_iChannel3 = None

g_bufferSound_iChannel0 = None
g_bufferSound_iChannel1 = None
g_bufferSound_iChannel2 = None
g_bufferSound_iChannel3 = None

bufferA = None
bufferB = None
bufferC = None
bufferD = None
bufferCubemap = None
bufferSound = None

g_face_color = "gray"
g_win_zoom = 1.0
g_win_size = None

def compute_dispatch(fc, fcd, entry):
    pass

def shader_dispatch(fc, fcd, entry):
    pass

def CameraState_defval():
	return [h_f3_defval(), h_f3_defval(), 0.0]

def CameraState_vPos_set(lhs, rhs):
	lhs[0] = h_copy_f3(rhs)
	return rhs

def CameraState_vTarget_set(lhs, rhs):
	lhs[1] = h_copy_f3(rhs)
	return rhs

def CameraState_fFov_set(lhs, rhs):
	lhs[2] = rhs
	return rhs

def CameraState_vPos(lhs):
	return lhs[0]

def CameraState_fFov(lhs):
	return lhs[2]

def t_ArrRayInfo_defval(writable):
	return [h_t_f3_defval(writable), h_t_af3_defval(12, writable), h_t_af3_defval(12, writable), h_t_af_defval(12, writable), h_t_af_defval(12, writable), h_t_af_defval(12, writable), h_t_ai_defval(12, writable), h_t_af_defval(12, writable), h_t_af3_defval(12, writable), h_t_af3_defval(12, writable), h_t_ai_defval(12, writable), h_t_ai_defval(12, writable)]

def h_copy_t_ArrRayInfo(v):
	return [h_copy_f3(v[0]), h_copy_f3_x12(v[1]), h_copy_f3_x12(v[2]), h_copy_f_x12(v[3]), h_copy_f_x12(v[4]), h_copy_f_x12(v[5]), h_copy_i_x12(v[6]), h_copy_f_x12(v[7]), h_copy_f3_x12(v[8]), h_copy_f3_x12(v[9]), h_copy_i_x12(v[10]), h_copy_i_x12(v[11])]

def h_copy_f3_x12(v):
	return array_copy(v)
def h_copy_f_x12(v):
	return array_copy(v)
def h_copy_i_x12(v):
	return array_copy(v)
def ArrRayInfo_vRayOrigin(lhs):
	return lhs[1]

def ArrRayInfo_vRayDir(lhs):
	return lhs[2]

def ArrRayInfo_fStartDist(lhs):
	return lhs[3]

def ArrRayInfo_fLengthRemaining(lhs):
	return lhs[4]

def ArrRayInfo_fRefractiveIndex(lhs):
	return lhs[5]

def ArrRayInfo_vAmount(lhs):
	return lhs[9]

def ArrRayInfo_iChild0(lhs):
	return lhs[10]

def ArrRayInfo_iChild1(lhs):
	return lhs[11]

def t_RayInfo_defval(writable):
	return [h_t_f3_defval(writable), h_t_f3_defval(writable), h_t_f_defval(writable), h_t_f_defval(writable), h_t_f_defval(writable), h_t_i_defval(writable), h_t_f_defval(writable), h_t_f3_defval(writable), h_t_f3_defval(writable), h_t_i_defval(writable), h_t_i_defval(writable)]

def h_copy_t_RayInfo(v):
	return [h_copy_f3(v[0]), h_copy_f3(v[1]), v[2], v[3], v[4], v[5], v[6], h_copy_f3(v[7]), h_copy_f3(v[8]), v[9], v[10]]

def RayInfo_fLengthRemaining(lhs):
	return lhs[3]

def RayInfo_iChild0_set(lhs, rhs):
	lhs[9] = rhs
	return rhs

def RayInfo_iChild1_set(lhs, rhs):
	lhs[10] = rhs
	return rhs

def RayInfo_fStartDist(lhs):
	return lhs[2]

def RayInfo_iObjectId(lhs):
	return lhs[5]

def RayInfo_vRayOrigin(lhs):
	return lhs[0]

def RayInfo_vRayDir(lhs):
	return lhs[1]

def SceneResult_fDist(lhs):
	return lhs[0]

def RayInfo_fDist_set(lhs, rhs):
	lhs[6] = rhs
	return rhs

def RayInfo_vColor_set(lhs, rhs):
	lhs[7] = h_copy_f3(rhs)
	return rhs

def SceneResult_iObjectId(lhs):
	return lhs[1]

def h_where_t_n_t_RayInfo_t_RayInfo(b, y, n):
	return [h_where_t_n_t_v_t_v(b, y[0], n[0]), h_where_t_n_t_v_t_v(b, y[1], n[1]), h_where_t_n_t_n_t_n(b, y[2], n[2]), h_where_t_n_t_n_t_n(b, y[3], n[3]), h_where_t_n_t_n_t_n(b, y[4], n[4]), h_where_t_n_t_n_t_n(b, y[5], n[5]), h_where_t_n_t_n_t_n(b, y[6], n[6]), h_where_t_n_t_v_t_v(b, y[7], n[7]), h_where_t_n_t_v_t_v(b, y[8], n[8]), h_where_t_n_t_n_t_n(b, y[9], n[9]), h_where_t_n_t_n_t_n(b, y[10], n[10])]

def SurfaceInfo_vBumpNormal(lhs):
	return lhs[2]

def SurfaceInfo_vR0(lhs):
	return lhs[4]

def SurfaceInfo_fSmoothness(lhs):
	return lhs[5]

def SurfaceInfo_vAlbedo(lhs):
	return lhs[3]

def SurfaceLighting_vDiffuse(lhs):
	return lhs[0]

def SurfaceInfo_vEmissive(lhs):
	return lhs[6]

def SurfaceInfo_fTransparency(lhs):
	return lhs[7]

def RayInfo_vAmount(lhs):
	return lhs[8]

def RayInfo_vAmount_set(lhs, rhs):
	lhs[8] = h_copy_f3(rhs)
	return rhs

def SurfaceInfo_vPos(lhs):
	return lhs[0]

def RayInfo_vRayOrigin_set(lhs, rhs):
	lhs[0] = h_copy_f3(rhs)
	return rhs

def RayInfo_iObjectId_set(lhs, rhs):
	lhs[5] = rhs
	return rhs

def RayInfo_fRefractiveIndex(lhs):
	return lhs[4]

def SurfaceInfo_fRefractiveIndex(lhs):
	return lhs[8]

def RayInfo_vRayDir_set(lhs, rhs):
	lhs[1] = h_copy_f3(rhs)
	return rhs

def SurfaceInfo_vNormal(lhs):
	return lhs[1]

def RayInfo_fStartDist_set(lhs, rhs):
	lhs[2] = rhs
	return rhs

def RayInfo_fLengthRemaining_set(lhs, rhs):
	lhs[3] = rhs
	return rhs

def RayInfo_fDist(lhs):
	return lhs[6]

def RayInfo_fRefractiveIndex_set(lhs, rhs):
	lhs[4] = rhs
	return rhs

def RayInfo_vColor(lhs):
	return lhs[7]

def h_where_t_n_t_ArrRayInfo_t_ArrRayInfo(b, y, n):
	return [h_where_t_n_t_v_t_v(b, y[0], n[0]), h_where_t_n_t_av_t_av(b, y[1], n[1]), h_where_t_n_t_av_t_av(b, y[2], n[2]), h_where_t_n_t_an_t_an(b, y[3], n[3]), h_where_t_n_t_an_t_an(b, y[4], n[4]), h_where_t_n_t_an_t_an(b, y[5], n[5]), h_where_t_n_t_an_t_an(b, y[6], n[6]), h_where_t_n_t_an_t_an(b, y[7], n[7]), h_where_t_n_t_av_t_av(b, y[8], n[8]), h_where_t_n_t_av_t_av(b, y[9], n[9]), h_where_t_n_t_an_t_an(b, y[10], n[10]), h_where_t_n_t_an_t_an(b, y[11], n[11])]

def SurfaceLighting_vSpecular(lhs):
	return lhs[1]

def h_where_n_t_RayInfo_t_RayInfo(b, y, n):
	return [h_where_n_t_v_t_v(b, y[0], n[0]), h_where_n_t_v_t_v(b, y[1], n[1]), h_where_n_t_n_t_n(b, y[2], n[2]), h_where_n_t_n_t_n(b, y[3], n[3]), h_where_n_t_n_t_n(b, y[4], n[4]), h_where_n_t_n_t_n(b, y[5], n[5]), h_where_n_t_n_t_n(b, y[6], n[6]), h_where_n_t_v_t_v(b, y[7], n[7]), h_where_n_t_v_t_v(b, y[8], n[8]), h_where_n_t_n_t_n(b, y[9], n[9]), h_where_n_t_n_t_n(b, y[10], n[10])]

def h_where_n_t_ArrRayInfo_t_ArrRayInfo(b, y, n):
	return [h_where_n_t_v_t_v(b, y[0], n[0]), h_where_n_t_av_t_av(b, y[1], n[1]), h_where_n_t_av_t_av(b, y[2], n[2]), h_where_n_t_an_t_an(b, y[3], n[3]), h_where_n_t_an_t_an(b, y[4], n[4]), h_where_n_t_an_t_an(b, y[5], n[5]), h_where_n_t_an_t_an(b, y[6], n[6]), h_where_n_t_an_t_an(b, y[7], n[7]), h_where_n_t_av_t_av(b, y[8], n[8]), h_where_n_t_av_t_av(b, y[9], n[9]), h_where_n_t_an_t_an(b, y[10], n[10]), h_where_n_t_an_t_an(b, y[11], n[11])]

def RayInfo_iChild0(lhs):
	return lhs[9]

def RayInfo_iChild1(lhs):
	return lhs[10]

def SceneResult_defval():
	return [0.0, 0, h_f3_defval()]

def h_copy_SceneResult(v):
	return [v[0], v[1], h_copy_f3(v[2])]

def SceneResult_fDist_set(lhs, rhs):
	lhs[0] = rhs
	return rhs

def h_where_n_SceneResult_SceneResult(b, y, n):
	return [h_where_n_n_n(b, y[0], n[0]), h_where_n_n_n(b, y[1], n[1]), h_where_n_v_v(b, y[2], n[2])]

def ArrRayInfo_vColor(lhs):
	return lhs[8]

def ArrRayInfo_fDist(lhs):
	return lhs[7]

def ArrRayInfo_iObjectId(lhs):
	return lhs[6]

def t_SceneResult_defval(writable):
	return [h_t_f_defval(writable), h_t_i_defval(writable), h_t_f3_defval(writable)]

def SceneResult_vUVW_set(lhs, rhs):
	lhs[2] = h_copy_f3(rhs)
	return rhs

def SceneResult_iObjectId_set(lhs, rhs):
	lhs[1] = rhs
	return rhs

def h_copy_t_SceneResult(v):
	return [v[0], v[1], h_copy_f3(v[2])]

def h_where_t_n_t_SceneResult_t_SceneResult(b, y, n):
	return [h_where_t_n_t_n_t_n(b, y[0], n[0]), h_where_t_n_t_n_t_n(b, y[1], n[1]), h_where_t_n_t_v_t_v(b, y[2], n[2])]

def h_where_n_t_SceneResult_t_SceneResult(b, y, n):
	return [h_where_n_t_n_t_n(b, y[0], n[0]), h_where_n_t_n_t_n(b, y[1], n[1]), h_where_n_t_v_t_v(b, y[2], n[2])]

def t_SurfaceInfo_defval(writable):
	return [h_t_f3_defval(writable), h_t_f3_defval(writable), h_t_f3_defval(writable), h_t_f3_defval(writable), h_t_f3_defval(writable), h_t_f_defval(writable), h_t_f3_defval(writable), h_t_f_defval(writable), h_t_f_defval(writable)]

def SurfaceInfo_vPos_set(lhs, rhs):
	lhs[0] = h_copy_f3(rhs)
	return rhs

def SurfaceInfo_vNormal_set(lhs, rhs):
	lhs[1] = h_copy_f3(rhs)
	return rhs

def SurfaceInfo_vBumpNormal_set(lhs, rhs):
	lhs[2] = h_copy_f3(rhs)
	return rhs

def SurfaceInfo_vAlbedo_set(lhs, rhs):
	lhs[3] = h_copy_f3(rhs)
	return rhs

def SurfaceInfo_vR0_set(lhs, rhs):
	lhs[4] = h_copy_f3(rhs)
	return rhs

def SurfaceInfo_fSmoothness_set(lhs, rhs):
	lhs[5] = rhs
	return rhs

def SurfaceInfo_vEmissive_set(lhs, rhs):
	lhs[6] = h_copy_f3(rhs)
	return rhs

def SurfaceInfo_fTransparency_set(lhs, rhs):
	lhs[7] = rhs
	return rhs

def SurfaceInfo_fRefractiveIndex_set(lhs, rhs):
	lhs[8] = rhs
	return rhs

def h_copy_t_SurfaceInfo(v):
	return [h_copy_f3(v[0]), h_copy_f3(v[1]), h_copy_f3(v[2]), h_copy_f3(v[3]), h_copy_f3(v[4]), v[5], h_copy_f3(v[6]), v[7], v[8]]

def SceneResult_vUVW(lhs):
	return lhs[2]

def h_where_t_n_t_SurfaceInfo_t_SurfaceInfo(b, y, n):
	return [h_where_t_n_t_v_t_v(b, y[0], n[0]), h_where_t_n_t_v_t_v(b, y[1], n[1]), h_where_t_n_t_v_t_v(b, y[2], n[2]), h_where_t_n_t_v_t_v(b, y[3], n[3]), h_where_t_n_t_v_t_v(b, y[4], n[4]), h_where_t_n_t_n_t_n(b, y[5], n[5]), h_where_t_n_t_v_t_v(b, y[6], n[6]), h_where_t_n_t_n_t_n(b, y[7], n[7]), h_where_t_n_t_n_t_n(b, y[8], n[8])]

def t_SurfaceLighting_defval(writable):
	return [h_t_f3_defval(writable), h_t_f3_defval(writable)]

def SurfaceLighting_vDiffuse_set(lhs, rhs):
	lhs[0] = h_copy_f3(rhs)
	return rhs

def SurfaceLighting_vSpecular_set(lhs, rhs):
	lhs[1] = h_copy_f3(rhs)
	return rhs

def h_copy_t_SurfaceLighting(v):
	return [h_copy_f3(v[0]), h_copy_f3(v[1])]

def CameraState_vTarget(lhs):
	return lhs[1]

def Cam_GetWorldToCameraRotMatrix_CameraState(cameraState):
	vForward = h_normalize_v(h_sub_vf_vf(CameraState_vTarget(cameraState), CameraState_vPos(cameraState)))
	vRight = h_normalize_v(h_cross_v_v(h_f3_n_n_n(0.0, 1.0, 0.0), vForward))
	vUp = h_normalize_v(h_cross_v_v(vForward, vRight))
	return h_f3x3_n3_n3_n3(h_cast_f3_f3(vRight), h_cast_f3_f3(vUp), h_cast_f3_f3(vForward))


def Light_GIV_f_f_arr(dotNV, k):
	return h_div_f_t_f(1.0, h_add_t_f_t_f(h_mul_t_f_t_f(h_add_t_f_f(dotNV, 9.99999974E-5), h_sub_f_t_f(1.0, k)), k))

def SmoothMin_f_f_f_arr(a, b, k):
	h = h_clamp_t_n_n_n(h_add_f_t_f(0.5, h_div_t_f_f(h_mul_f_t_f(0.5, h_sub_t_f_t_f(b, a)), k)), 0.0, 1.0)
	return h_sub_t_f_t_f(h_lerp_t_n_t_n_t_n(b, a, h), h_mul_t_f_t_f(h_mul_f_t_f(k, h), h_sub_f_t_f(1.0, h)))

def Scene_GetDistance_f3_i_arr1(vPos, iInsideObject):
	vWineGlassPos = h_f3_n_n_n(0.0, 0.0, -2.0)
	vBowlPos = h_f3_n_n_n(1.0, 0.0, 1.0)
	result = t_SceneResult_defval(True)
	SceneResult_fDist_set(result, swizzle_t_n3_y(vPos))
	SceneResult_vUVW_set(result, h_copy_t_f3(vPos))
	SceneResult_iObjectId_set(result, h_broadcast_i(False, 0))
	vSphere1Pos = h_add_vf_vf(vBowlPos, h_f3_n_n_n(0.400000006, 0.5, 0.200000003))
	sphereResult1 = t_SceneResult_defval(True)
	SceneResult_vUVW_set(sphereResult1, h_sub_t_vf_vf(vPos, vSphere1Pos))
	SceneResult_fDist_set(sphereResult1, h_min_t_n_t_n(SceneResult_fDist(result), h_sub_t_f_f(h_length_t_v(h_sub_t_vf_vf(vPos, vSphere1Pos)), 0.400000006)))
	SceneResult_iObjectId_set(sphereResult1, h_broadcast_i(False, 4))
	param = h_copy_t_SceneResult(result)
	param = Scene_Union_SceneResult_SceneResult_arr(param, sphereResult1)
	result = h_copy_t_SceneResult(param)
	vSphere2Pos = h_f3_n_n_n(2.20000005, 0.5, -0.899999976)
	sphereResult2 = t_SceneResult_defval(True)
	SceneResult_vUVW_set(sphereResult2, swizzle_t_n3_zyx(h_sub_t_vf_vf(vPos, vSphere2Pos)))
	SceneResult_fDist_set(sphereResult2, h_sub_t_f_f(h_length_t_v(h_sub_t_vf_vf(vPos, vSphere2Pos)), 0.5))
	SceneResult_iObjectId_set(sphereResult2, h_broadcast_i(False, 4))
	param_1 = h_copy_t_SceneResult(result)
	param_1 = Scene_Union_SceneResult_SceneResult_arr(param_1, sphereResult2)
	result = h_copy_t_SceneResult(param_1)
	_vecif_113_exp = h_greater_than_t_n_n(SceneResult_fDist(result), 10.0)
	if any_ifexp_true_t_n(_vecif_113_exp):
		_vecif_113_result = h_copy_t_SceneResult(result)
		SceneResult_iObjectId_set(_vecif_113_result, h_broadcast_i(False, -1))
		result = h_where_t_n_t_SceneResult_t_SceneResult(_vecif_113_exp, _vecif_113_result, result)
	wineResult = t_SceneResult_defval(True)
	SceneResult_vUVW_set(wineResult, h_copy_t_f3(vPos))
	SceneResult_iObjectId_set(wineResult, h_broadcast_i(False, 2))
	param_2 = h_sub_t_vf_vf(vPos, vWineGlassPos)
	SceneResult_fDist_set(wineResult, GetDistanceWine_f3_arr(param_2))
	fRadius = 1.0
	fHeight = 1.0
	glassResult = t_SceneResult_defval(True)
	SceneResult_iObjectId_set(glassResult, h_broadcast_i(False, 1))
	SceneResult_fDist_set(glassResult, h_sub_t_f_f(h_length_t_v(h_sub_t_vf_vf(vPos, h_f3_n_n_n(-2.0, 1.0, 1.0))), 1.0))
	param_3 = h_sub_t_vf_vf(vPos, vBowlPos)
	SceneResult_fDist_set(glassResult, h_min_t_n_t_n(SceneResult_fDist(glassResult), GetDistanceBowl_f3_arr(param_3)))
	SceneResult_vUVW_set(glassResult, swizzle_t_n3_xzy(vPos))
	param_4 = h_sub_t_vf_vf(vPos, vWineGlassPos)
	SceneResult_fDist_set(glassResult, h_min_t_n_t_n(SceneResult_fDist(glassResult), GetDistanceWineGlass_f3_arr(param_4)))
	param_5 = h_copy_t_SceneResult(wineResult)
	param_5 = Scene_Trim_SceneResult_SceneResult_arr(h_copy_t_SceneResult(param_5), glassResult)
	wineResult = h_copy_t_SceneResult(param_5)
	SceneResult_fDist_set(wineResult, h_sub_t_f_f(SceneResult_fDist(wineResult), 9.99999974E-5))
	_vecif_114_exp = h_equal_n_n(iInsideObject, 1)
	if any_ifexp_true_n(_vecif_114_exp):
		_vecif_114_glassResult = h_copy_t_SceneResult(glassResult)
		SceneResult_fDist_set(_vecif_114_glassResult, h_sub_t_f(SceneResult_fDist(_vecif_114_glassResult)))
		glassResult = h_where_n_t_SceneResult_t_SceneResult(_vecif_114_exp, _vecif_114_glassResult, glassResult)
	_vecif_115_exp = h_equal_n_n(iInsideObject, 2)
	if any_ifexp_true_n(_vecif_115_exp):
		_vecif_115_wineResult = h_copy_t_SceneResult(wineResult)
		SceneResult_fDist_set(_vecif_115_wineResult, h_sub_t_f(SceneResult_fDist(_vecif_115_wineResult)))
		wineResult = h_where_n_t_SceneResult_t_SceneResult(_vecif_115_exp, _vecif_115_wineResult, wineResult)
	param_6 = h_copy_t_SceneResult(result)
	param_6 = Scene_Union_SceneResult_SceneResult_arr(param_6, glassResult)
	result = h_copy_t_SceneResult(param_6)
	param_7 = h_copy_t_SceneResult(result)
	param_7 = Scene_Union_SceneResult_SceneResult_arr(param_7, wineResult)
	result = h_copy_t_SceneResult(param_7)
	return result

def Light_Add_SurfaceLighting_SurfaceInfo_f3_f3_f3_arr(lighting, surface, vViewDir, vLightDir, vLightColour):
	fNDotL = h_clamp_t_n_n_n(h_dot_v_t_v(vLightDir, SurfaceInfo_vBumpNormal(surface)), 0.0, 1.0)
	SurfaceLighting_vDiffuse_set(lighting, h_add_t_vf_t_vf(SurfaceLighting_vDiffuse(lighting), h_mul_t_vf_t_f(vLightColour, fNDotL)))
	vH = h_normalize_t_v(h_add_t_vf_vf(h_sub_t_vf(vViewDir), vLightDir))
	fNdotV = h_clamp_t_n_n_n(h_dot_t_v_t_v(h_sub_t_vf(vViewDir), SurfaceInfo_vBumpNormal(surface)), 0.0, 1.0)
	fNdotH = h_clamp_t_n_n_n(h_dot_t_v_t_v(SurfaceInfo_vBumpNormal(surface), vH), 0.0, 1.0)
	alpha = h_sub_f_t_f(1.0, SurfaceInfo_fSmoothness(surface))
	alphaSqr = h_mul_t_f_t_f(alpha, alpha)
	denom = h_add_t_f_f(h_mul_t_f_t_f(h_mul_t_f_t_f(fNdotH, fNdotH), h_sub_t_f_f(alphaSqr, 1.0)), 1.0)
	d = h_div_t_f_t_f(alphaSqr, h_mul_t_f_t_f(h_mul_f_t_f(3.14159274, denom), denom))
	k = h_div_t_f_f(alpha, 2.0)
	param = fNDotL
	param_1 = k
	param_2 = fNdotV
	param_3 = k
	vis = h_mul_t_f_t_f(Light_GIV_f_f_arr(param, param_1), Light_GIV_f_f_arr(param_2, param_3))
	fSpecularIntensity = h_mul_t_f_t_f(h_mul_t_f_t_f(d, vis), fNDotL)
	SurfaceLighting_vSpecular_set(lighting, h_add_t_vf_t_vf(SurfaceLighting_vSpecular(lighting), h_mul_t_vf_t_f(vLightColour, fSpecularIntensity)))
	return lighting

def Scene_TraceShadow_f3_f3_f_f_arr(vRayOrigin, vRayDir, fMinDist, fLightDist):
	res = h_broadcast_f(False, 1.0)
	t = h_broadcast_f(False, fMinDist)
	_br_flag_22 = h_broadcast_b(False, False)
	i = 0
	while True:
		try:
			_vecif_110_exp_0 = h_not_t_n(_br_flag_22)
			if any_ifexp_true_t_n(_vecif_110_exp_0):
				_vecif_110_res = res
				_vecif_110_t = t
				_vecif_110__br_flag_22 = _br_flag_22
				_vecif_111_exp_0 = h_less_than_n_n(i, 16)
				if any_ifexp_true_n(_vecif_111_exp_0):
					_vecif_111_res = _vecif_110_res
					_vecif_111_t = _vecif_110_t
					_vecif_111__br_flag_22 = _vecif_110__br_flag_22
					h = SceneResult_fDist(Scene_GetDistance_f3_i_arr1(h_add_t_vf_t_vf(vRayOrigin, h_mul_vf_t_f(vRayDir, _vecif_111_t)), -1))
					_vecif_111_res = h_min_t_n_t_n(_vecif_111_res, h_div_t_f_t_f(h_mul_f_t_f(8.0, h), _vecif_111_t))
					_vecif_111_t = h_add_t_f_t_f(_vecif_111_t, h_clamp_t_n_n_n(h, 0.0199999996, 0.100000001))
					_vecif_112_exp = h_or_t_n_t_n(h_less_than_t_n_n(h, 9.99999974E-5), h_greater_than_t_n_n(_vecif_111_t, fLightDist))
					if any_ifexp_true_t_n(_vecif_112_exp):
						_vecif_112__br_flag_22 = _vecif_111__br_flag_22
						_vecif_112__br_flag_22 = h_broadcast_b(False, True)
						_vecif_111__br_flag_22 = h_where_t_n_t_n_t_n(_vecif_112_exp, _vecif_112__br_flag_22, _vecif_111__br_flag_22)
					_vecif_110_res = h_where_n_t_n_t_n(_vecif_111_exp_0, _vecif_111_res, _vecif_110_res)
					_vecif_110_t = h_where_n_t_n_t_n(_vecif_111_exp_0, _vecif_111_t, _vecif_110_t)
					_vecif_110__br_flag_22 = h_where_n_t_n_t_n(_vecif_111_exp_0, _vecif_111__br_flag_22, _vecif_110__br_flag_22)
				if not_any_ifexp_true_n(_vecif_111_exp_0):
					_vecif_111__br_flag_22 = _vecif_110__br_flag_22
					_vecif_111__br_flag_22 = h_broadcast_b(False, True)
					#condition: not _vecif_111_exp_0
					_vecif_110__br_flag_22 = h_where_n_t_n_t_n(_vecif_111_exp_0, _vecif_110__br_flag_22, _vecif_111__br_flag_22)
				res = h_where_t_n_t_n_t_n(_vecif_110_exp_0, _vecif_110_res, res)
				t = h_where_t_n_t_n_t_n(_vecif_110_exp_0, _vecif_110_t, t)
				_br_flag_22 = h_where_t_n_t_n_t_n(_vecif_110_exp_0, _vecif_110__br_flag_22, _br_flag_22)
			if not_any_ifexp_true_t_n(_vecif_110_exp_0):
				break
		finally:
			i = h_inc_i(i)
	return h_clamp_t_n_n_n(res, 0.0, 1.0)

def Scene_Trim_SceneResult_SceneResult_arr(a, b):
	_vecif_109_exp = h_less_than_t_n_t_n(SceneResult_fDist(a), h_sub_t_f(SceneResult_fDist(b)))
	if any_ifexp_true_t_n(_vecif_109_exp):
		_vecif_109_a = h_copy_t_SceneResult(a)
		SceneResult_fDist_set(_vecif_109_a, h_sub_t_f(SceneResult_fDist(b)))
		a = h_where_t_n_t_SceneResult_t_SceneResult(_vecif_109_exp, _vecif_109_a, a)
	return a

def GetDistanceWineGlass_f3_arr(vPos):
	vPos2 = h_t_f2_t_n_t_n(h_length_t_v(swizzle_t_n3_xz(vPos)), swizzle_t_n3_y(vPos))
	vSphOrigin = h_f2_n_n(0.0, 2.0)
	vSphPos = h_sub_t_vf_vf(vPos2, vSphOrigin)
	vClosest = h_copy_t_f2(vSphPos)
	_vecif_108_exp = h_greater_than_t_n_n(swizzle_t_n2_y(vClosest), 0.300000012)
	if any_ifexp_true_t_n(_vecif_108_exp):
		_vecif_108_vClosest = h_copy_t_f2(vClosest)
		swizzle_set_t_n2_y(_vecif_108_vClosest, h_broadcast_f(False, 0.300000012))
		vClosest = h_where_t_n_t_v_t_v(_vecif_108_exp, _vecif_108_vClosest, vClosest)
	vClosest = h_mul_t_vf_f(h_normalize_t_v(vClosest), 0.600000024)
	fBowlDistance = h_sub_t_f_f(h_distance_t_v_t_v(vClosest, vSphPos), 0.0149999997)
	vStemClosest = h_copy_t_f2(vPos2)
	swizzle_set_t_n2_x(vStemClosest, h_broadcast_f(False, 0.0))
	swizzle_set_t_n2_y(vStemClosest, h_clamp_t_n_n_n(swizzle_t_n2_y(vStemClosest), 0.0, 1.35000002))
	fStemRadius = h_sub_t_f_f(swizzle_t_n2_y(vStemClosest), 0.5)
	fStemRadius = h_add_t_f_f(h_mul_t_f_f(h_mul_t_f_t_f(fStemRadius, fStemRadius), 0.0199999996), 0.0299999993)
	fStemDistance = h_sub_t_f_t_f(h_distance_t_v_t_v(vPos2, vStemClosest), fStemRadius)
	norm = h_f2_n_n(0.371390671, 0.928476691)
	vBaseClosest = vPos2
	fBaseDistance = h_sub_t_f_f(h_dot_t_v_v(h_sub_t_vf_vf(vPos2, h_f2_n_n(0.0, 0.100000001)), norm), 0.200000003)
	fBaseDistance = h_max_t_n_t_n(fBaseDistance, h_sub_t_f_f(swizzle_t_n2_x(vPos2), 0.5))
	param = fBowlDistance
	param_1 = fStemDistance
	param_2 = 0.200000003
	fDistance = SmoothMin_f_f_f_arr(param, param_1, 0.200000003)
	param_3 = fDistance
	param_4 = fBaseDistance
	param_5 = 0.200000003
	fDistance = SmoothMin_f_f_f_arr(param_3, param_4, 0.200000003)
	fDistance = h_max_t_n_t_n(fDistance, h_sub_t_f_f(swizzle_t_n2_y(vSphPos), 0.5))
	return fDistance

def GetDistanceBowl_f3_arr(vPos):
	vPos2 = h_t_f2_t_n_t_n(h_length_t_v(swizzle_t_n3_xz(vPos)), swizzle_t_n3_y(vPos))
	vSphOrigin = h_f2_n_n(0.0, 0.730000019)
	vSphPos = h_sub_t_vf_vf(vPos2, vSphOrigin)
	vClosest = h_copy_t_f2(vSphPos)
	_vecif_106_exp = h_greater_than_t_n_n(swizzle_t_n2_y(vClosest), 0.100000001)
	if any_ifexp_true_t_n(_vecif_106_exp):
		_vecif_106_vClosest = h_copy_t_f2(vClosest)
		swizzle_set_t_n2_y(_vecif_106_vClosest, h_broadcast_f(False, 0.100000001))
		vClosest = h_where_t_n_t_v_t_v(_vecif_106_exp, _vecif_106_vClosest, vClosest)
	_vecif_107_exp = h_less_than_t_n_n(swizzle_t_n2_y(vClosest), -0.699999988)
	if any_ifexp_true_t_n(_vecif_107_exp):
		_vecif_107_vClosest = h_copy_t_f2(vClosest)
		swizzle_set_t_n2_y(_vecif_107_vClosest, h_broadcast_f(False, -0.699999988))
		vClosest = h_where_t_n_t_v_t_v(_vecif_107_exp, _vecif_107_vClosest, vClosest)
	r = h_sqrt_t_n(h_sub_f_t_f(1.0, h_mul_t_f_t_f(swizzle_t_n2_y(vClosest), swizzle_t_n2_y(vClosest))))
	swizzle_set_t_n2_x(vClosest, h_copy_t_f(r))
	fBowlDistance = h_distance_t_v_t_v(vClosest, vSphPos)
	vClosest = h_copy_t_f2(vSphPos)
	swizzle_set_t_n2_y(vClosest, h_broadcast_f(False, -0.699999988))
	r = h_sqrt_t_n(h_sub_f_t_f(1.0, h_mul_t_f_t_f(swizzle_t_n2_y(vClosest), swizzle_t_n2_y(vClosest))))
	swizzle_set_t_n2_x(vClosest, h_min_t_n_t_n(swizzle_t_n2_x(vClosest), r))
	fBaseDistance = h_distance_t_v_t_v(vClosest, vSphPos)
	fBowlDistance = h_min_t_n_t_n(fBowlDistance, fBaseDistance)
	return h_sub_t_f_f(fBowlDistance, 0.0299999993)

def GetDistanceWine_f3_arr(vPos):
	global iTime
	vLocalPos = h_copy_t_f3(vPos)
	swizzle_set_t_n3_y(vLocalPos, h_sub_t_f_f(swizzle_t_n3_y(vLocalPos), 2.0))
	vPos2 = h_t_f2_t_n_t_n(h_length_t_v(swizzle_t_n3_xz(vLocalPos)), swizzle_t_n3_y(vLocalPos))
	vSphOrigin = swizzle_n_xx(0.0)
	vSphPos = h_sub_t_vf_vf(vPos2, vSphOrigin)
	fBowlDistance = h_add_t_f_f(h_sub_t_f_f(h_length_t_v(vSphPos), 0.600000024), 0.00999999977)
	vWaterNormal = h_f3_n_n_n(0.0, 1.0, 0.0)
	swizzle_set_n3_x(vWaterNormal, h_mul_f_f(h_sin_n(h_mul_f_f(iTime, 5.0)), 0.00999999977))
	swizzle_set_n3_z(vWaterNormal, h_mul_f_f(h_cos_n(h_mul_f_f(iTime, 5.0)), 0.00999999977))
	vWaterNormal = h_normalize_v(vWaterNormal)
	fWaterLevel = h_sub_t_f_f(h_dot_t_v_v(vLocalPos, vWaterNormal), 0.100000001)
	return h_max_t_n_t_n(fBowlDistance, fWaterLevel)

def Scene_Union_SceneResult_SceneResult_arr(a, b):
	_vecif_105_exp = h_less_than_t_n_t_n(SceneResult_fDist(b), SceneResult_fDist(a))
	if any_ifexp_true_t_n(_vecif_105_exp):
		_vecif_105_a = a
		_vecif_105_a = b
		a = h_where_t_n_t_SceneResult_t_SceneResult(_vecif_105_exp, _vecif_105_a, a)
	return a

def Scene_GetAmbientOcclusion_f3_f3_arr(vPos, vDir):
	fOcclusion = h_broadcast_f(False, 0.0)
	fScale = 1.0
	_br_flag_27 = False
	i = 0
	while True:
		try:
			_vecif_103_exp_0 = h_not_n(_br_flag_27)
			if any_ifexp_true_n(_vecif_103_exp_0):
				_vecif_103_fOcclusion = fOcclusion
				_vecif_103_fScale = fScale
				_vecif_103__br_flag_27 = _br_flag_27
				_vecif_104_exp_0 = h_less_than_n_n(i, 5)
				if any_ifexp_true_n(_vecif_104_exp_0):
					_vecif_104_fOcclusion = _vecif_103_fOcclusion
					_vecif_104_fScale = _vecif_103_fScale
					fOffsetDist = h_add_f_f(0.00999999977, h_div_f_f(h_mul_f_f(1.0, h_cast_f_i(i)), 4.0))
					vAOPos = h_add_t_vf_t_vf(h_mul_t_vf_f(vDir, fOffsetDist), vPos)
					fDist = SceneResult_fDist(Scene_GetDistance_f3_i_arr1(vAOPos, -1))
					_vecif_104_fOcclusion = h_add_t_f_t_f(_vecif_104_fOcclusion, h_mul_t_f_f(h_sub_f_t_f(fOffsetDist, fDist), _vecif_104_fScale))
					_vecif_104_fScale = h_mul_f_f(_vecif_104_fScale, 0.400000006)
					_vecif_103_fOcclusion = h_where_n_t_n_t_n(_vecif_104_exp_0, _vecif_104_fOcclusion, _vecif_103_fOcclusion)
					_vecif_103_fScale = h_where_n_n_n(_vecif_104_exp_0, _vecif_104_fScale, _vecif_103_fScale)
				if not_any_ifexp_true_n(_vecif_104_exp_0):
					_vecif_104__br_flag_27 = _vecif_103__br_flag_27
					_vecif_104__br_flag_27 = True
					#condition: not _vecif_104_exp_0
					_vecif_103__br_flag_27 = h_where_n_n_n(_vecif_104_exp_0, _vecif_103__br_flag_27, _vecif_104__br_flag_27)
				fOcclusion = h_where_n_t_n_t_n(_vecif_103_exp_0, _vecif_103_fOcclusion, fOcclusion)
				fScale = h_where_n_n_n(_vecif_103_exp_0, _vecif_103_fScale, fScale)
				_br_flag_27 = h_where_n_n_n(_vecif_103_exp_0, _vecif_103__br_flag_27, _br_flag_27)
			if not_any_ifexp_true_n(_vecif_103_exp_0):
				break
		finally:
			i = h_inc_i(i)
	return h_clamp_t_n_n_n(h_sub_f_t_f(1.0, h_mul_f_t_f(2.0, fOcclusion)), 0.0, 1.0)

def Light_AddDirectional_SurfaceLighting_SurfaceInfo_f3_f3_f3_arr(lighting, surface, vViewDir, vLightDir, vLightColour):
	fAttenuation = 1.0
	arg = 0.100000001
	arg_1 = 10.0
	fShadowFactor = Scene_TraceShadow_f3_f3_f_f_arr(SurfaceInfo_vPos(surface), vLightDir, 0.100000001, 10.0)
	param = lighting
	param_1 = surface
	param = Light_Add_SurfaceLighting_SurfaceInfo_f3_f3_f3_arr(h_copy_t_SurfaceLighting(param), param_1, vViewDir, vLightDir, h_mul_t_vf_f(h_mul_vf_t_f(vLightColour, fShadowFactor), 1.0))
	lighting = param
	return lighting

def Scene_GetNormal_f3_i_arr(vPos, iInsideObject):
	_func_ret_val_19 = h_t_f3_defval(False)
	_func_ret_flag_19 = h_broadcast_b(False, False)
	e = h_f2_n_n(-1.0, 1.0)
	vNormal = h_add_t_vf_t_vf(h_add_t_vf_t_vf(h_add_t_vf_t_vf(h_mul_vf_t_f(swizzle_n2_yxx(e), SceneResult_fDist(Scene_GetDistance_f3_i_arr(h_add_t_vf_vf(vPos, h_mul_vf_f(swizzle_n2_yxx(e), 0.00100000005)), iInsideObject))), h_mul_vf_t_f(swizzle_n2_xxy(e), SceneResult_fDist(Scene_GetDistance_f3_i_arr(h_add_t_vf_vf(vPos, h_mul_vf_f(swizzle_n2_xxy(e), 0.00100000005)), iInsideObject)))), h_mul_vf_t_f(swizzle_n2_xyx(e), SceneResult_fDist(Scene_GetDistance_f3_i_arr(h_add_t_vf_vf(vPos, h_mul_vf_f(swizzle_n2_xyx(e), 0.00100000005)), iInsideObject)))), h_mul_vf_t_f(swizzle_n2_yyy(e), SceneResult_fDist(Scene_GetDistance_f3_i_arr(h_add_t_vf_vf(vPos, h_mul_vf_f(swizzle_n2_yyy(e), 0.00100000005)), iInsideObject))))
	_vecif_101_exp = h_less_than_t_n_n(h_dot_t_v_t_v(vNormal, vNormal), 9.99999974E-6)
	if any_ifexp_true_t_n(_vecif_101_exp):
		_vecif_101__func_ret_flag_19 = _func_ret_flag_19
		_vecif_101__func_ret_val_19 = _func_ret_val_19
		_vecif_101__func_ret_flag_19 = h_broadcast_b(False, True)
		_vecif_101__func_ret_val_19 = h_broadcast_f3(False, h_f3_n_n_n(0.0, 1.0, 0.0))
		_func_ret_flag_19 = h_where_t_n_t_n_t_n(_vecif_101_exp, _vecif_101__func_ret_flag_19, _func_ret_flag_19)
		_func_ret_val_19 = h_where_t_n_t_v_t_v(_vecif_101_exp, _vecif_101__func_ret_val_19, _func_ret_val_19)
	_vecif_102_exp = h_not_t_n(_func_ret_flag_19)
	if any_ifexp_true_t_n(_vecif_102_exp):
		_vecif_102__func_ret_flag_19 = _func_ret_flag_19
		_vecif_102__func_ret_val_19 = _func_ret_val_19
		_vecif_102__func_ret_flag_19 = h_broadcast_b(False, True)
		_vecif_102__func_ret_val_19 = h_normalize_t_v(vNormal)
		_func_ret_flag_19 = h_where_t_n_t_n_t_n(_vecif_102_exp, _vecif_102__func_ret_flag_19, _func_ret_flag_19)
		_func_ret_val_19 = h_where_t_n_t_v_t_v(_vecif_102_exp, _vecif_102__func_ret_val_19, _func_ret_val_19)
	return _func_ret_val_19

def Scene_GetDistance_f3_i_arr(vPos, iInsideObject):
	vWineGlassPos = h_f3_n_n_n(0.0, 0.0, -2.0)
	vBowlPos = h_f3_n_n_n(1.0, 0.0, 1.0)
	result = t_SceneResult_defval(True)
	SceneResult_fDist_set(result, swizzle_t_n3_y(vPos))
	SceneResult_vUVW_set(result, h_copy_t_f3(vPos))
	SceneResult_iObjectId_set(result, h_broadcast_i(False, 0))
	vSphere1Pos = h_add_vf_vf(vBowlPos, h_f3_n_n_n(0.400000006, 0.5, 0.200000003))
	sphereResult1 = t_SceneResult_defval(True)
	SceneResult_vUVW_set(sphereResult1, h_sub_t_vf_vf(vPos, vSphere1Pos))
	SceneResult_fDist_set(sphereResult1, h_min_t_n_t_n(SceneResult_fDist(result), h_sub_t_f_f(h_length_t_v(h_sub_t_vf_vf(vPos, vSphere1Pos)), 0.400000006)))
	SceneResult_iObjectId_set(sphereResult1, h_broadcast_i(False, 4))
	param = h_copy_t_SceneResult(result)
	param = Scene_Union_SceneResult_SceneResult_arr(param, sphereResult1)
	result = h_copy_t_SceneResult(param)
	vSphere2Pos = h_f3_n_n_n(2.20000005, 0.5, -0.899999976)
	sphereResult2 = t_SceneResult_defval(True)
	SceneResult_vUVW_set(sphereResult2, swizzle_t_n3_zyx(h_sub_t_vf_vf(vPos, vSphere2Pos)))
	SceneResult_fDist_set(sphereResult2, h_sub_t_f_f(h_length_t_v(h_sub_t_vf_vf(vPos, vSphere2Pos)), 0.5))
	SceneResult_iObjectId_set(sphereResult2, h_broadcast_i(False, 4))
	param_1 = h_copy_t_SceneResult(result)
	param_1 = Scene_Union_SceneResult_SceneResult_arr(param_1, sphereResult2)
	result = h_copy_t_SceneResult(param_1)
	_vecif_98_exp = h_greater_than_t_n_n(SceneResult_fDist(result), 10.0)
	if any_ifexp_true_t_n(_vecif_98_exp):
		_vecif_98_result = h_copy_t_SceneResult(result)
		SceneResult_iObjectId_set(_vecif_98_result, h_broadcast_i(False, -1))
		result = h_where_t_n_t_SceneResult_t_SceneResult(_vecif_98_exp, _vecif_98_result, result)
	wineResult = t_SceneResult_defval(True)
	SceneResult_vUVW_set(wineResult, h_copy_t_f3(vPos))
	SceneResult_iObjectId_set(wineResult, h_broadcast_i(False, 2))
	param_2 = h_sub_t_vf_vf(vPos, vWineGlassPos)
	SceneResult_fDist_set(wineResult, GetDistanceWine_f3_arr(param_2))
	fRadius = 1.0
	fHeight = 1.0
	glassResult = t_SceneResult_defval(True)
	SceneResult_iObjectId_set(glassResult, h_broadcast_i(False, 1))
	SceneResult_fDist_set(glassResult, h_sub_t_f_f(h_length_t_v(h_sub_t_vf_vf(vPos, h_f3_n_n_n(-2.0, 1.0, 1.0))), 1.0))
	param_3 = h_sub_t_vf_vf(vPos, vBowlPos)
	SceneResult_fDist_set(glassResult, h_min_t_n_t_n(SceneResult_fDist(glassResult), GetDistanceBowl_f3_arr(param_3)))
	SceneResult_vUVW_set(glassResult, swizzle_t_n3_xzy(vPos))
	param_4 = h_sub_t_vf_vf(vPos, vWineGlassPos)
	SceneResult_fDist_set(glassResult, h_min_t_n_t_n(SceneResult_fDist(glassResult), GetDistanceWineGlass_f3_arr(param_4)))
	param_5 = h_copy_t_SceneResult(wineResult)
	param_5 = Scene_Trim_SceneResult_SceneResult_arr(h_copy_t_SceneResult(param_5), glassResult)
	wineResult = h_copy_t_SceneResult(param_5)
	SceneResult_fDist_set(wineResult, h_sub_t_f_f(SceneResult_fDist(wineResult), 9.99999974E-5))
	_vecif_99_exp = h_equal_t_n_n(iInsideObject, 1)
	if any_ifexp_true_t_n(_vecif_99_exp):
		_vecif_99_glassResult = h_copy_t_SceneResult(glassResult)
		SceneResult_fDist_set(_vecif_99_glassResult, h_sub_t_f(SceneResult_fDist(_vecif_99_glassResult)))
		glassResult = h_where_t_n_t_SceneResult_t_SceneResult(_vecif_99_exp, _vecif_99_glassResult, glassResult)
	_vecif_100_exp = h_equal_t_n_n(iInsideObject, 2)
	if any_ifexp_true_t_n(_vecif_100_exp):
		_vecif_100_wineResult = h_copy_t_SceneResult(wineResult)
		SceneResult_fDist_set(_vecif_100_wineResult, h_sub_t_f(SceneResult_fDist(_vecif_100_wineResult)))
		wineResult = h_where_t_n_t_SceneResult_t_SceneResult(_vecif_100_exp, _vecif_100_wineResult, wineResult)
	param_6 = h_copy_t_SceneResult(result)
	param_6 = Scene_Union_SceneResult_SceneResult_arr(param_6, glassResult)
	result = h_copy_t_SceneResult(param_6)
	param_7 = h_copy_t_SceneResult(result)
	param_7 = Scene_Union_SceneResult_SceneResult_arr(param_7, wineResult)
	result = h_copy_t_SceneResult(param_7)
	return result

def RayInfo_Clear_i_ArrRayInfo_arr(i, arrRayInfo):
	global _664
	rayInfo = _664
	array_set_t_an3_n(ArrRayInfo_vRayOrigin(arrRayInfo), i, h_broadcast_f3(False, RayInfo_vRayOrigin(rayInfo)))
	array_set_t_an3_n(ArrRayInfo_vRayDir(arrRayInfo), i, h_broadcast_f3(False, RayInfo_vRayDir(rayInfo)))
	array_set_t_an_n(ArrRayInfo_fStartDist(arrRayInfo), i, h_broadcast_f(False, RayInfo_fStartDist(rayInfo)))
	array_set_t_an_n(ArrRayInfo_fLengthRemaining(arrRayInfo), i, h_broadcast_f(False, RayInfo_fLengthRemaining(rayInfo)))
	array_set_t_an_n(ArrRayInfo_fRefractiveIndex(arrRayInfo), i, h_broadcast_f(False, RayInfo_fRefractiveIndex(rayInfo)))
	array_set_t_an_n(ArrRayInfo_iObjectId(arrRayInfo), i, h_broadcast_i(False, RayInfo_iObjectId(rayInfo)))
	array_set_t_an_n(ArrRayInfo_fDist(arrRayInfo), i, h_broadcast_f(False, RayInfo_fDist(rayInfo)))
	array_set_t_an3_n(ArrRayInfo_vColor(arrRayInfo), i, h_broadcast_f3(False, RayInfo_vColor(rayInfo)))
	array_set_t_an3_n(ArrRayInfo_vAmount(arrRayInfo), i, h_broadcast_f3(False, RayInfo_vAmount(rayInfo)))
	array_set_t_an_n(ArrRayInfo_iChild0(arrRayInfo), i, h_broadcast_i(False, RayInfo_iChild0(rayInfo)))
	array_set_t_an_n(ArrRayInfo_iChild1(arrRayInfo), i, h_broadcast_i(False, RayInfo_iChild1(rayInfo)))
	return arrRayInfo

def RayStack_Set_i_RayInfo_ArrRayInfo_arr1(i, rayInfo, rayStack):
	array_set_t_an3_n(ArrRayInfo_vRayOrigin(rayStack), i, h_copy_t_f3(RayInfo_vRayOrigin(rayInfo)))
	array_set_t_an3_n(ArrRayInfo_vRayDir(rayStack), i, h_copy_t_f3(RayInfo_vRayDir(rayInfo)))
	array_set_t_an_n(ArrRayInfo_fStartDist(rayStack), i, RayInfo_fStartDist(rayInfo))
	array_set_t_an_n(ArrRayInfo_fLengthRemaining(rayStack), i, RayInfo_fLengthRemaining(rayInfo))
	array_set_t_an_n(ArrRayInfo_fRefractiveIndex(rayStack), i, RayInfo_fRefractiveIndex(rayInfo))
	array_set_t_an_n(ArrRayInfo_iObjectId(rayStack), i, RayInfo_iObjectId(rayInfo))
	array_set_t_an_n(ArrRayInfo_fDist(rayStack), i, RayInfo_fDist(rayInfo))
	array_set_t_an3_n(ArrRayInfo_vColor(rayStack), i, h_copy_t_f3(RayInfo_vColor(rayInfo)))
	array_set_t_an3_n(ArrRayInfo_vAmount(rayStack), i, h_copy_t_f3(RayInfo_vAmount(rayInfo)))
	array_set_t_an_n(ArrRayInfo_iChild0(rayStack), i, RayInfo_iChild0(rayInfo))
	array_set_t_an_n(ArrRayInfo_iChild1(rayStack), i, RayInfo_iChild1(rayInfo))
	return rayStack

def FX_Apply_f3_f3_f3_f_arr(vColor, vRayOrigin, vRayDir, fDist):
	return vColor

def Env_ApplyAtmosphere_f3_f3_f3_f_i_arr(vColor, vRayOrigin, vRayDir, fDist, iInsideObject):
	vResult = vColor
	_vecif_94_exp = h_or_t_n_t_n(h_equal_t_n_n(iInsideObject, 1), h_equal_t_n_n(iInsideObject, 2))
	if any_ifexp_true_t_n(_vecif_94_exp):
		_vecif_94_vResult = vResult
		vExtCol = h_broadcast_f3(False, swizzle_n_xxx(0.0))
		_vecif_95_exp_0 = h_equal_t_n_n(iInsideObject, 2)
		if any_ifexp_true_t_n(_vecif_95_exp_0):
			_vecif_95_vExtCol = vExtCol
			_vecif_95_vExtCol = h_broadcast_f3(False, h_f3_n_n_n(0.0, 0.5, 0.990000009))
			vExtCol = h_where_t_n_t_v_t_v(_vecif_95_exp_0, _vecif_95_vExtCol, vExtCol)
		if not_all_ifexp_true_t_n(_vecif_95_exp_0):
			_vecif_95_vExtCol = vExtCol
			_vecif_96_exp = h_greater_than_t_n_n(swizzle_t_n3_z(vRayOrigin), 0.0)
			if any_ifexp_true_t_n(_vecif_96_exp):
				_vecif_96_vExtCol = _vecif_95_vExtCol
				_vecif_97_exp_0 = h_less_than_t_n_n(swizzle_t_n3_x(vRayOrigin), 0.0)
				if any_ifexp_true_t_n(_vecif_97_exp_0):
					_vecif_97_vExtCol = _vecif_96_vExtCol
					_vecif_97_vExtCol = h_broadcast_f3(False, h_f3_n_n_n(0.990000009, 0.990000009, 0.0))
					_vecif_96_vExtCol = h_where_t_n_t_v_t_v(_vecif_97_exp_0, _vecif_97_vExtCol, _vecif_96_vExtCol)
				if not_all_ifexp_true_t_n(_vecif_97_exp_0):
					_vecif_97_vExtCol = _vecif_96_vExtCol
					_vecif_97_vExtCol = h_broadcast_f3(False, h_f3_n_n_n(0.0, 0.800000011, 0.200000003))
					_vecif_97_vExtCol = h_mul_t_vf_f(_vecif_97_vExtCol, 20.0)
					#condition: not _vecif_97_exp_0
					_vecif_96_vExtCol = h_where_t_n_t_v_t_v(_vecif_97_exp_0, _vecif_96_vExtCol, _vecif_97_vExtCol)
				_vecif_95_vExtCol = h_where_t_n_t_v_t_v(_vecif_96_exp, _vecif_96_vExtCol, _vecif_95_vExtCol)
			#condition: not _vecif_95_exp_0
			vExtCol = h_where_t_n_t_v_t_v(_vecif_95_exp_0, vExtCol, _vecif_95_vExtCol)
		_vecif_94_vResult = h_mul_t_vf_t_vf(_vecif_94_vResult, h_exp_t_v(h_mul_t_vf_t_f(h_sub_t_vf(vExtCol), fDist)))
		vResult = h_where_t_n_t_v_t_v(_vecif_94_exp, _vecif_94_vResult, vResult)
	return vResult

def RayStack_Get_i_ArrRayInfo_arr1(i, rayStack):
	rayInfo = t_RayInfo_defval(True)
	RayInfo_vRayOrigin_set(rayInfo, h_copy_t_f3(array_get_t_an3_n(ArrRayInfo_vRayOrigin(rayStack), i)))
	RayInfo_vRayDir_set(rayInfo, h_copy_t_f3(array_get_t_an3_n(ArrRayInfo_vRayDir(rayStack), i)))
	RayInfo_fStartDist_set(rayInfo, array_get_t_an_n(ArrRayInfo_fStartDist(rayStack), i))
	RayInfo_fLengthRemaining_set(rayInfo, array_get_t_an_n(ArrRayInfo_fLengthRemaining(rayStack), i))
	RayInfo_fRefractiveIndex_set(rayInfo, array_get_t_an_n(ArrRayInfo_fRefractiveIndex(rayStack), i))
	RayInfo_iObjectId_set(rayInfo, array_get_t_an_n(ArrRayInfo_iObjectId(rayStack), i))
	RayInfo_fDist_set(rayInfo, array_get_t_an_n(ArrRayInfo_fDist(rayStack), i))
	RayInfo_vColor_set(rayInfo, h_copy_t_f3(array_get_t_an3_n(ArrRayInfo_vColor(rayStack), i)))
	RayInfo_vAmount_set(rayInfo, h_copy_t_f3(array_get_t_an3_n(ArrRayInfo_vAmount(rayStack), i)))
	RayInfo_iChild0_set(rayInfo, array_get_t_an_n(ArrRayInfo_iChild0(rayStack), i))
	RayInfo_iChild1_set(rayInfo, array_get_t_an_n(ArrRayInfo_iChild1(rayStack), i))
	return rayInfo

def RayStack_Set_i_RayInfo_ArrRayInfo_arr(i, rayInfo, rayStack):
	array_set_t_an3_t_n(ArrRayInfo_vRayOrigin(rayStack), i, h_copy_t_f3(RayInfo_vRayOrigin(rayInfo)))
	array_set_t_an3_t_n(ArrRayInfo_vRayDir(rayStack), i, h_copy_t_f3(RayInfo_vRayDir(rayInfo)))
	array_set_t_an_t_n(ArrRayInfo_fStartDist(rayStack), i, RayInfo_fStartDist(rayInfo))
	array_set_t_an_t_n(ArrRayInfo_fLengthRemaining(rayStack), i, RayInfo_fLengthRemaining(rayInfo))
	array_set_t_an_t_n(ArrRayInfo_fRefractiveIndex(rayStack), i, RayInfo_fRefractiveIndex(rayInfo))
	array_set_t_an_t_n(ArrRayInfo_iObjectId(rayStack), i, RayInfo_iObjectId(rayInfo))
	array_set_t_an_t_n(ArrRayInfo_fDist(rayStack), i, RayInfo_fDist(rayInfo))
	array_set_t_an3_t_n(ArrRayInfo_vColor(rayStack), i, h_copy_t_f3(RayInfo_vColor(rayInfo)))
	array_set_t_an3_t_n(ArrRayInfo_vAmount(rayStack), i, h_copy_t_f3(RayInfo_vAmount(rayInfo)))
	array_set_t_an_t_n(ArrRayInfo_iChild0(rayStack), i, RayInfo_iChild0(rayInfo))
	array_set_t_an_t_n(ArrRayInfo_iChild1(rayStack), i, RayInfo_iChild1(rayInfo))
	return rayStack

def Light_GetFresnel_f3_f3_f3_f_arr(vView, vNormal, vR0, fGloss):
	NdotV = h_max_n_t_n(0.0, h_dot_t_v_t_v(vView, vNormal))
	return h_add_t_vf_t_vf(vR0, h_mul_t_vf_t_f(h_mul_t_vf_t_f(h_sub_vf_t_vf(swizzle_n_xxx(1.0), vR0), h_pow_t_n_n(h_sub_f_t_f(1.0, NdotV), 5.0)), h_pow_t_n_n(fGloss, 20.0)))

def Scene_GetSurfaceLighting_f3_SurfaceInfo_arr(vViewDir, surfaceInfo):
	global g_vSunDir, g_vSunColor, g_vAmbientColor
	surfaceLighting = t_SurfaceLighting_defval(True)
	SurfaceLighting_vDiffuse_set(surfaceLighting, h_broadcast_f3(False, swizzle_n_xxx(0.0)))
	SurfaceLighting_vSpecular_set(surfaceLighting, h_broadcast_f3(False, swizzle_n_xxx(0.0)))
	param = h_copy_t_SurfaceLighting(surfaceLighting)
	param_1 = surfaceInfo
	param = Light_AddDirectional_SurfaceLighting_SurfaceInfo_f3_f3_f3_arr(param, param_1, vViewDir, g_vSunDir, g_vSunColor)
	surfaceLighting = h_copy_t_SurfaceLighting(param)
	fAO = Scene_GetAmbientOcclusion_f3_f3_arr(SurfaceInfo_vPos(surfaceInfo), SurfaceInfo_vNormal(surfaceInfo))
	SurfaceLighting_vDiffuse_set(surfaceLighting, h_add_t_vf_t_vf(SurfaceLighting_vDiffuse(surfaceLighting), h_mul_vf_t_f(g_vAmbientColor, h_mul_t_f_t_f(fAO, h_add_t_f_f(h_mul_t_f_f(swizzle_t_n3_y(SurfaceInfo_vBumpNormal(surfaceInfo)), 0.5), 0.5)))))
	return surfaceLighting

def Scene_GetSurfaceInfo_f3_f3_SceneResult_i_arr(vRayOrigin, vRayDir, traceResult, iInsideObject):
	global bufferA_iChannel2, _bufferA_iChannel2_sampler, bufferA_iChannel3, _bufferA_iChannel3_sampler
	surfaceInfo = t_SurfaceInfo_defval(True)
	SurfaceInfo_vPos_set(surfaceInfo, h_add_t_vf_t_vf(vRayOrigin, h_mul_t_vf_t_f(vRayDir, SceneResult_fDist(traceResult))))
	SurfaceInfo_vNormal_set(surfaceInfo, Scene_GetNormal_f3_i_arr(SurfaceInfo_vPos(surfaceInfo), iInsideObject))
	SurfaceInfo_vBumpNormal_set(surfaceInfo, h_copy_t_f3(SurfaceInfo_vNormal(surfaceInfo)))
	SurfaceInfo_vAlbedo_set(surfaceInfo, h_broadcast_f3(False, swizzle_n_xxx(1.0)))
	SurfaceInfo_vR0_set(surfaceInfo, h_broadcast_f3(False, swizzle_n_xxx(0.00999999977)))
	SurfaceInfo_fSmoothness_set(surfaceInfo, h_broadcast_f(False, 1.0))
	SurfaceInfo_vEmissive_set(surfaceInfo, h_broadcast_f3(False, swizzle_n_xxx(0.0)))
	SurfaceInfo_fTransparency_set(surfaceInfo, h_broadcast_f(False, 0.0))
	SurfaceInfo_fRefractiveIndex_set(surfaceInfo, h_broadcast_f(False, 1.0))
	_vecif_84_exp = h_equal_t_n_n(SceneResult_iObjectId(traceResult), 0)
	if any_ifexp_true_t_n(_vecif_84_exp):
		_vecif_84_surfaceInfo = h_copy_t_SurfaceInfo(surfaceInfo)
		SurfaceInfo_vR0_set(_vecif_84_surfaceInfo, h_broadcast_f3(False, swizzle_n_xxx(0.0199999996)))
		SurfaceInfo_vAlbedo_set(_vecif_84_surfaceInfo, swizzle_t_n4_xyz(Texture2D__float4_T_SampleLevel_n_t_v_n(bufferA_iChannel2, _bufferA_iChannel2_sampler, h_mul_t_vf_f(swizzle_t_n3_xz(SceneResult_vUVW(traceResult)), 0.5), 0.0)))
		SurfaceInfo_vAlbedo_set(_vecif_84_surfaceInfo, h_mul_t_vf_t_vf(SurfaceInfo_vAlbedo(_vecif_84_surfaceInfo), SurfaceInfo_vAlbedo(_vecif_84_surfaceInfo)))
		SurfaceInfo_fSmoothness_set(_vecif_84_surfaceInfo, h_clamp_t_n_n_n(h_sub_f_t_f(1.0, h_mul_t_f_f(h_mul_t_f_t_f(swizzle_t_n3_x(SurfaceInfo_vAlbedo(_vecif_84_surfaceInfo)), swizzle_t_n3_x(SurfaceInfo_vAlbedo(_vecif_84_surfaceInfo))), 2.0)), 0.0, 1.0))
		SurfaceInfo_vAlbedo_set(_vecif_84_surfaceInfo, h_mul_t_vf_f(SurfaceInfo_vAlbedo(_vecif_84_surfaceInfo), 0.25))
		fDist = h_length_t_v(swizzle_t_n3_xz(SurfaceInfo_vPos(_vecif_84_surfaceInfo)))
		fCheckerAmount = h_clamp_t_n_n_n(h_add_t_f_t_f(h_sub_f_t_f(1.0, h_mul_t_f_f(fDist, 0.100000001)), h_mul_t_f_f(swizzle_t_n3_x(SurfaceInfo_vAlbedo(_vecif_84_surfaceInfo)), 0.5)), 0.0, 1.0)
		fChecker = h_step_t_n_n(h_frac_t_n(h_mul_t_f_f(h_add_t_f_t_f(h_floor_t_n(swizzle_t_n3_x(SceneResult_vUVW(traceResult))), h_floor_t_n(swizzle_t_n3_z(SceneResult_vUVW(traceResult)))), 0.5)), 0.25)
		vChecker = h_t_f3_defval(False)
		_vecif_85_exp_0 = h_greater_than_t_n_n(fChecker, 0.0)
		if any_ifexp_true_t_n(_vecif_85_exp_0):
			_vecif_85_vChecker = vChecker
			_vecif_85_vChecker = h_broadcast_f3(False, swizzle_n_xxx(1.0))
			vChecker = h_where_t_n_t_v_t_v(_vecif_85_exp_0, _vecif_85_vChecker, vChecker)
		if not_all_ifexp_true_t_n(_vecif_85_exp_0):
			_vecif_85_vChecker = vChecker
			_vecif_85_vChecker = h_broadcast_f3(False, swizzle_n_xxx(0.100000001))
			#condition: not _vecif_85_exp_0
			vChecker = h_where_t_n_t_v_t_v(_vecif_85_exp_0, vChecker, _vecif_85_vChecker)
		SurfaceInfo_vAlbedo_set(_vecif_84_surfaceInfo, h_lerp_t_v_t_v_t_v(SurfaceInfo_vAlbedo(_vecif_84_surfaceInfo), vChecker, swizzle_t_n_xxx(fCheckerAmount)))
		SurfaceInfo_vR0_set(_vecif_84_surfaceInfo, h_lerp_t_v_v_t_v(SurfaceInfo_vR0(_vecif_84_surfaceInfo), swizzle_n_xxx(0.100000001), swizzle_t_n_xxx(fCheckerAmount)))
		SurfaceInfo_fSmoothness_set(_vecif_84_surfaceInfo, h_lerp_t_n_n_t_n(SurfaceInfo_fSmoothness(_vecif_84_surfaceInfo), 1.0, fCheckerAmount))
		surfaceInfo = h_where_t_n_t_SurfaceInfo_t_SurfaceInfo(_vecif_84_exp, _vecif_84_surfaceInfo, surfaceInfo)
	_vecif_86_exp = h_equal_t_n_n(SceneResult_iObjectId(traceResult), 4)
	if any_ifexp_true_t_n(_vecif_86_exp):
		_vecif_86_surfaceInfo = h_copy_t_SurfaceInfo(surfaceInfo)
		fStripe = h_step_t_n_n(h_frac_t_n(h_dot_t_v_v(h_mul_t_vf_f(SceneResult_vUVW(traceResult), 5.0), h_f3_n_n_n(1.0, 0.200000003, 0.400000006))), 0.5)
		_vecif_87_exp_0 = h_greater_than_t_n_n(fStripe, 0.0)
		if any_ifexp_true_t_n(_vecif_87_exp_0):
			_vecif_87_surfaceInfo = h_copy_t_SurfaceInfo(_vecif_86_surfaceInfo)
			SurfaceInfo_vAlbedo_set(_vecif_87_surfaceInfo, h_broadcast_f3(False, h_f3_n_n_n(0.100000001, 0.0500000007, 1.0)))
			_vecif_86_surfaceInfo = h_where_t_n_t_SurfaceInfo_t_SurfaceInfo(_vecif_87_exp_0, _vecif_87_surfaceInfo, _vecif_86_surfaceInfo)
		if not_all_ifexp_true_t_n(_vecif_87_exp_0):
			_vecif_87_surfaceInfo = h_copy_t_SurfaceInfo(_vecif_86_surfaceInfo)
			SurfaceInfo_vAlbedo_set(_vecif_87_surfaceInfo, h_broadcast_f3(False, h_f3_n_n_n(1.0, 0.0500000007, 0.100000001)))
			#condition: not _vecif_87_exp_0
			_vecif_86_surfaceInfo = h_where_t_n_t_SurfaceInfo_t_SurfaceInfo(_vecif_87_exp_0, _vecif_86_surfaceInfo, _vecif_87_surfaceInfo)
		surfaceInfo = h_where_t_n_t_SurfaceInfo_t_SurfaceInfo(_vecif_86_exp, _vecif_86_surfaceInfo, surfaceInfo)
	_vecif_88_exp = h_equal_t_n_n(SceneResult_iObjectId(traceResult), 1)
	if any_ifexp_true_t_n(_vecif_88_exp):
		_vecif_88_surfaceInfo = h_copy_t_SurfaceInfo(surfaceInfo)
		SurfaceInfo_vR0_set(_vecif_88_surfaceInfo, h_broadcast_f3(False, swizzle_n_xxx(0.0199999996)))
		vAlbedo = swizzle_t_n4_xyz(Texture2D__float4_T_SampleLevel_n_t_v_n(bufferA_iChannel3, _bufferA_iChannel3_sampler, h_mul_t_vf_f(swizzle_t_n3_xy(SceneResult_vUVW(traceResult)), 2.0), 0.0))
		vAlbedo = h_mul_t_vf_t_vf(vAlbedo, vAlbedo)
		vAlbedo = h_mul_t_vf_vf(vAlbedo, h_f3_n_n_n(1.0, 0.100000001, 0.5))
		SurfaceInfo_vAlbedo_set(_vecif_88_surfaceInfo, h_copy_t_f3(vAlbedo))
		SurfaceInfo_fSmoothness_set(_vecif_88_surfaceInfo, h_clamp_t_n_n_n(h_sub_f_t_f(1.0, h_mul_t_f_f(swizzle_t_n3_x(SurfaceInfo_vAlbedo(_vecif_88_surfaceInfo)), 2.0)), 0.0, 0.899999976))
		SurfaceInfo_fTransparency_set(_vecif_88_surfaceInfo, h_clamp_t_n_n_n(h_add_t_f_t_f(h_mul_t_f_f(swizzle_t_n3_y(SurfaceInfo_vPos(_vecif_88_surfaceInfo)), 5.0), h_mul_t_f_f(swizzle_t_n3_y(SurfaceInfo_vAlbedo(_vecif_88_surfaceInfo)), 3.0)), 0.0, 1.0))
		_1469 = h_less_than_t_n_n(swizzle_t_n3_x(SurfaceInfo_vPos(_vecif_88_surfaceInfo)), 0.0)
		_1476 = h_t_b_defval(False)
		_vecif_89_exp_0 = h_not_t_n(_1469)
		if any_ifexp_true_t_n(_vecif_89_exp_0):
			_vecif_89__1476 = _1476
			_vecif_89__1476 = h_less_than_t_n_n(swizzle_t_n3_z(SurfaceInfo_vPos(_vecif_88_surfaceInfo)), 0.0)
			_1476 = h_where_t_n_t_n_t_n(_vecif_89_exp_0, _vecif_89__1476, _1476)
		if not_all_ifexp_true_t_n(_vecif_89_exp_0):
			_vecif_89__1476 = _1476
			_vecif_89__1476 = _1469
			#condition: not _vecif_89_exp_0
			_1476 = h_where_t_n_t_n_t_n(_vecif_89_exp_0, _1476, _vecif_89__1476)
		_vecif_90_exp = _1476
		if any_ifexp_true_t_n(_vecif_90_exp):
			_vecif_90_surfaceInfo = h_copy_t_SurfaceInfo(_vecif_88_surfaceInfo)
			SurfaceInfo_vAlbedo_set(_vecif_90_surfaceInfo, h_broadcast_f3(False, swizzle_n_xxx(0.0)))
			SurfaceInfo_fSmoothness_set(_vecif_90_surfaceInfo, h_broadcast_f(False, 0.899999976))
			SurfaceInfo_fTransparency_set(_vecif_90_surfaceInfo, h_sub_f_t_f(1.0, h_mul_t_f_f(swizzle_t_n3_y(vAlbedo), 0.200000003)))
			_vecif_88_surfaceInfo = h_where_t_n_t_SurfaceInfo_t_SurfaceInfo(_vecif_90_exp, _vecif_90_surfaceInfo, _vecif_88_surfaceInfo)
		SurfaceInfo_fRefractiveIndex_set(_vecif_88_surfaceInfo, h_broadcast_f(False, 1.5))
		fLipStickDist = h_sub_t_f_f(h_length_t_v(h_sub_t_vf_vf(SurfaceInfo_vPos(_vecif_88_surfaceInfo), h_f3_n_n_n(0.300000012, 3.0999999, -2.9000001))), 1.0)
		_vecif_91_exp = h_less_than_t_n_n(fLipStickDist, 0.0)
		if any_ifexp_true_t_n(_vecif_91_exp):
			_vecif_91_surfaceInfo = h_copy_t_SurfaceInfo(_vecif_88_surfaceInfo)
			SurfaceInfo_fTransparency_set(_vecif_91_surfaceInfo, h_clamp_t_n_n_n(h_sub_t_f_t_f(h_add_f_t_f(1.0, h_mul_t_f_f(fLipStickDist, 2.0)), swizzle_t_n3_x(vAlbedo)), 0.0, 1.0))
			SurfaceInfo_vAlbedo_set(_vecif_91_surfaceInfo, h_mul_vf_t_f(h_f3_n_n_n(0.5, 0.0, 0.0), h_sub_f_t_f(1.0, SurfaceInfo_fTransparency(_vecif_91_surfaceInfo))))
			_vecif_88_surfaceInfo = h_where_t_n_t_SurfaceInfo_t_SurfaceInfo(_vecif_91_exp, _vecif_91_surfaceInfo, _vecif_88_surfaceInfo)
		surfaceInfo = h_where_t_n_t_SurfaceInfo_t_SurfaceInfo(_vecif_88_exp, _vecif_88_surfaceInfo, surfaceInfo)
	_vecif_92_exp = h_equal_t_n_n(SceneResult_iObjectId(traceResult), 2)
	if any_ifexp_true_t_n(_vecif_92_exp):
		_vecif_92_surfaceInfo = h_copy_t_SurfaceInfo(surfaceInfo)
		SurfaceInfo_vR0_set(_vecif_92_surfaceInfo, h_broadcast_f3(False, swizzle_n_xxx(0.0199999996)))
		SurfaceInfo_vAlbedo_set(_vecif_92_surfaceInfo, h_broadcast_f3(False, swizzle_n_xxx(0.0)))
		SurfaceInfo_fSmoothness_set(_vecif_92_surfaceInfo, h_broadcast_f(False, 0.899999976))
		SurfaceInfo_fTransparency_set(_vecif_92_surfaceInfo, h_broadcast_f(False, 1.0))
		SurfaceInfo_fRefractiveIndex_set(_vecif_92_surfaceInfo, h_broadcast_f(False, 1.29999995))
		surfaceInfo = h_where_t_n_t_SurfaceInfo_t_SurfaceInfo(_vecif_92_exp, _vecif_92_surfaceInfo, surfaceInfo)
	_vecif_93_exp = h_equal_t_n_t_n(SceneResult_iObjectId(traceResult), iInsideObject)
	if any_ifexp_true_t_n(_vecif_93_exp):
		_vecif_93_surfaceInfo = h_copy_t_SurfaceInfo(surfaceInfo)
		SurfaceInfo_fRefractiveIndex_set(_vecif_93_surfaceInfo, h_broadcast_f(False, 1.0))
		surfaceInfo = h_where_t_n_t_SurfaceInfo_t_SurfaceInfo(_vecif_93_exp, _vecif_93_surfaceInfo, surfaceInfo)
	return surfaceInfo

def Env_GetSkyColor_f3_f3_arr(vViewPos, vViewDir):
	global bufferA_iChannel1, _bufferA_iChannel1_sampler
	vResult = h_broadcast_f4(True, h_f4_n_n_n_n(0.0, 0.0, 1.0, 1100.0))
	vEnvMap = swizzle_t_n4_xyz(TextureCube__float4_T_SampleLevel_n_t_v_n(bufferA_iChannel1, _bufferA_iChannel1_sampler, vViewDir, 0.0))
	vEnvMap = h_mul_t_vf_t_vf(vEnvMap, vEnvMap)
	kEnvmapExposure = 0.999000012
	_1954 = h_sub_t_vf(h_log2_t_v(h_sub_vf_t_vf(swizzle_n_xxx(1.0), h_mul_t_vf_f(vEnvMap, 0.999000012))))
	swizzle_set_t_n4_x(vResult, swizzle_t_n3_x(_1954))
	swizzle_set_t_n4_y(vResult, swizzle_t_n3_y(_1954))
	swizzle_set_t_n4_z(vResult, swizzle_t_n3_z(_1954))
	return vResult

def Scene_Trace_f3_f3_f_f_i_arr(vRayOrigin, vRayDir, minDist, maxDist, iInsideObject):
	result = t_SceneResult_defval(True)
	SceneResult_fDist_set(result, h_broadcast_f(False, 0.0))
	SceneResult_vUVW_set(result, h_broadcast_f3(False, swizzle_n_xxx(0.0)))
	SceneResult_iObjectId_set(result, h_broadcast_i(False, -1))
	t = minDist
	_br_flag_17 = h_broadcast_b(False, False)
	i = 0
	while True:
		try:
			_vecif_77_exp_0 = h_not_t_n(_br_flag_17)
			if any_ifexp_true_t_n(_vecif_77_exp_0):
				_vecif_77_result = h_copy_t_SceneResult(result)
				_vecif_77_t = t
				_vecif_77__br_flag_17 = _br_flag_17
				_vecif_78_exp_0 = h_less_than_n_n(i, 96)
				if any_ifexp_true_n(_vecif_78_exp_0):
					_vecif_78_result = h_copy_t_SceneResult(_vecif_77_result)
					_vecif_78_t = _vecif_77_t
					_vecif_78__br_flag_17 = _vecif_77__br_flag_17
					_vecif_78_result = Scene_GetDistance_f3_i_arr(h_add_t_vf_t_vf(vRayOrigin, h_mul_t_vf_t_f(vRayDir, _vecif_78_t)), iInsideObject)
					_vecif_78_t = h_add_t_f_t_f(_vecif_78_t, SceneResult_fDist(_vecif_78_result))
					_vecif_79_exp = h_less_than_t_n_n(h_abs_t_n(SceneResult_fDist(_vecif_78_result)), 0.00100000005)
					if any_ifexp_true_t_n(_vecif_79_exp):
						_vecif_79__br_flag_17 = _vecif_78__br_flag_17
						_vecif_79__br_flag_17 = h_broadcast_b(False, True)
						_vecif_78__br_flag_17 = h_where_t_n_t_n_t_n(_vecif_79_exp, _vecif_79__br_flag_17, _vecif_78__br_flag_17)
					_vecif_80_exp = h_not_t_n(_vecif_78__br_flag_17)
					if any_ifexp_true_t_n(_vecif_80_exp):
						_vecif_80_result = h_copy_t_SceneResult(_vecif_78_result)
						_vecif_80_t = _vecif_78_t
						_vecif_80__br_flag_17 = _vecif_78__br_flag_17
						_420 = h_equal_t_n_n(iInsideObject, -1)
						_427 = h_t_b_defval(False)
						_vecif_81_exp_0 = _420
						if any_ifexp_true_t_n(_vecif_81_exp_0):
							_vecif_81__427 = _427
							_vecif_81__427 = h_greater_than_t_n_n(h_abs_t_n(SceneResult_fDist(_vecif_80_result)), 0.100000001)
							_427 = h_where_t_n_t_n_t_n(_vecif_81_exp_0, _vecif_81__427, _427)
						if not_all_ifexp_true_t_n(_vecif_81_exp_0):
							_vecif_81__427 = _427
							_vecif_81__427 = _420
							#condition: not _vecif_81_exp_0
							_427 = h_where_t_n_t_n_t_n(_vecif_81_exp_0, _427, _vecif_81__427)
						_vecif_82_exp = _427
						if any_ifexp_true_t_n(_vecif_82_exp):
							_vecif_82_result = h_copy_t_SceneResult(_vecif_80_result)
							SceneResult_iObjectId_set(_vecif_82_result, h_broadcast_i(False, -1))
							_vecif_80_result = h_where_t_n_t_SceneResult_t_SceneResult(_vecif_82_exp, _vecif_82_result, _vecif_80_result)
						_vecif_83_exp = h_greater_than_t_n_t_n(_vecif_80_t, maxDist)
						if any_ifexp_true_t_n(_vecif_83_exp):
							_vecif_83_result = h_copy_t_SceneResult(_vecif_80_result)
							_vecif_83_t = _vecif_80_t
							_vecif_83__br_flag_17 = _vecif_80__br_flag_17
							SceneResult_iObjectId_set(_vecif_83_result, h_broadcast_i(False, -1))
							_vecif_83_t = maxDist
							_vecif_83__br_flag_17 = h_broadcast_b(False, True)
							_vecif_80_result = h_where_t_n_t_SceneResult_t_SceneResult(_vecif_83_exp, _vecif_83_result, _vecif_80_result)
							_vecif_80_t = h_where_t_n_t_n_t_n(_vecif_83_exp, _vecif_83_t, _vecif_80_t)
							_vecif_80__br_flag_17 = h_where_t_n_t_n_t_n(_vecif_83_exp, _vecif_83__br_flag_17, _vecif_80__br_flag_17)
						_vecif_78_result = h_where_t_n_t_SceneResult_t_SceneResult(_vecif_80_exp, _vecif_80_result, _vecif_78_result)
						_vecif_78_t = h_where_t_n_t_n_t_n(_vecif_80_exp, _vecif_80_t, _vecif_78_t)
						_vecif_78__br_flag_17 = h_where_t_n_t_n_t_n(_vecif_80_exp, _vecif_80__br_flag_17, _vecif_78__br_flag_17)
					_vecif_77_result = h_where_n_t_SceneResult_t_SceneResult(_vecif_78_exp_0, _vecif_78_result, _vecif_77_result)
					_vecif_77_t = h_where_n_t_n_t_n(_vecif_78_exp_0, _vecif_78_t, _vecif_77_t)
					_vecif_77__br_flag_17 = h_where_n_t_n_t_n(_vecif_78_exp_0, _vecif_78__br_flag_17, _vecif_77__br_flag_17)
				if not_any_ifexp_true_n(_vecif_78_exp_0):
					_vecif_78__br_flag_17 = _vecif_77__br_flag_17
					_vecif_78__br_flag_17 = h_broadcast_b(False, True)
					#condition: not _vecif_78_exp_0
					_vecif_77__br_flag_17 = h_where_n_t_n_t_n(_vecif_78_exp_0, _vecif_77__br_flag_17, _vecif_78__br_flag_17)
				result = h_where_t_n_t_SceneResult_t_SceneResult(_vecif_77_exp_0, _vecif_77_result, result)
				t = h_where_t_n_t_n_t_n(_vecif_77_exp_0, _vecif_77_t, t)
				_br_flag_17 = h_where_t_n_t_n_t_n(_vecif_77_exp_0, _vecif_77__br_flag_17, _br_flag_17)
			if not_any_ifexp_true_t_n(_vecif_77_exp_0):
				break
		finally:
			i = h_inc_i(i)
	SceneResult_fDist_set(result, h_copy_t_f(t))
	return result

def RayStack_Get_i_ArrRayInfo_arr(i, rayStack):
	rayInfo = t_RayInfo_defval(True)
	RayInfo_vRayOrigin_set(rayInfo, h_copy_t_f3(array_get_t_an3_t_n(ArrRayInfo_vRayOrigin(rayStack), i)))
	RayInfo_vRayDir_set(rayInfo, h_copy_t_f3(array_get_t_an3_t_n(ArrRayInfo_vRayDir(rayStack), i)))
	RayInfo_fStartDist_set(rayInfo, array_get_t_an_t_n(ArrRayInfo_fStartDist(rayStack), i))
	RayInfo_fLengthRemaining_set(rayInfo, array_get_t_an_t_n(ArrRayInfo_fLengthRemaining(rayStack), i))
	RayInfo_fRefractiveIndex_set(rayInfo, array_get_t_an_t_n(ArrRayInfo_fRefractiveIndex(rayStack), i))
	RayInfo_iObjectId_set(rayInfo, array_get_t_an_t_n(ArrRayInfo_iObjectId(rayStack), i))
	RayInfo_fDist_set(rayInfo, array_get_t_an_t_n(ArrRayInfo_fDist(rayStack), i))
	RayInfo_vColor_set(rayInfo, h_copy_t_f3(array_get_t_an3_t_n(ArrRayInfo_vColor(rayStack), i)))
	RayInfo_vAmount_set(rayInfo, h_copy_t_f3(array_get_t_an3_t_n(ArrRayInfo_vAmount(rayStack), i)))
	RayInfo_iChild0_set(rayInfo, array_get_t_an_t_n(ArrRayInfo_iChild0(rayStack), i))
	RayInfo_iChild1_set(rayInfo, array_get_t_an_t_n(ArrRayInfo_iChild1(rayStack), i))
	return rayInfo

def RayStack_Reset_ArrRayInfo_arr(rayStack):
	_br_flag_7 = False
	i = 0
	while True:
		try:
			_vecif_75_exp_0 = h_not_n(_br_flag_7)
			if any_ifexp_true_n(_vecif_75_exp_0):
				_vecif_75_rayStack = rayStack
				_vecif_75__br_flag_7 = _br_flag_7
				_vecif_76_exp_0 = h_less_than_n_n(i, 12)
				if any_ifexp_true_n(_vecif_76_exp_0):
					_vecif_76_rayStack = _vecif_75_rayStack
					param = i
					param_1 = _vecif_76_rayStack
					param_1 = RayInfo_Clear_i_ArrRayInfo_arr(param, h_copy_t_ArrRayInfo(param_1))
					_vecif_76_rayStack = param_1
					_vecif_75_rayStack = h_where_n_t_ArrRayInfo_t_ArrRayInfo(_vecif_76_exp_0, _vecif_76_rayStack, _vecif_75_rayStack)
				if not_any_ifexp_true_n(_vecif_76_exp_0):
					_vecif_76__br_flag_7 = _vecif_75__br_flag_7
					_vecif_76__br_flag_7 = True
					#condition: not _vecif_76_exp_0
					_vecif_75__br_flag_7 = h_where_n_n_n(_vecif_76_exp_0, _vecif_75__br_flag_7, _vecif_76__br_flag_7)
				rayStack = h_where_n_t_ArrRayInfo_t_ArrRayInfo(_vecif_75_exp_0, _vecif_75_rayStack, rayStack)
				_br_flag_7 = h_where_n_n_n(_vecif_75_exp_0, _vecif_75__br_flag_7, _br_flag_7)
			if not_any_ifexp_true_n(_vecif_75_exp_0):
				break
		finally:
			i = h_inc_i(i)
	return rayStack

def GetCoC_f_f_arr(fDistance, fPlaneInFocus_1):
	fAperture = 0.0500000007
	fFocalLength = 0.800000011
	return h_abs_t_n(h_div_t_f_t_f(h_mul_f_t_f(0.0500000007, h_mul_f_t_f(0.800000011, h_sub_t_f_f(fDistance, fPlaneInFocus_1))), h_mul_t_f_f(fDistance, h_sub_f_f(fPlaneInFocus_1, 0.800000011))))

def Scene_GetColorAndDepth_f3_f3_arr(vInRayOrigin, vInRayDir):
	vResultColor = swizzle_n_xxx(0.0)
	ix = h_broadcast_i(False, 0)
	stackCurrent = h_broadcast_i(False, 0)
	stackEnd = h_broadcast_i(False, 1)
	rayStack = t_ArrRayInfo_defval(True)
	param = h_copy_t_ArrRayInfo(rayStack)
	param = RayStack_Reset_ArrRayInfo_arr(param)
	rayStack = h_copy_t_ArrRayInfo(param)
	array_set_t_an3_n(ArrRayInfo_vRayOrigin(rayStack), 0, h_copy_t_f3(vInRayOrigin))
	array_set_t_an3_n(ArrRayInfo_vRayDir(rayStack), 0, h_copy_t_f3(vInRayDir))
	array_set_t_an_n(ArrRayInfo_fStartDist(rayStack), 0, h_broadcast_f(False, 0.0))
	array_set_t_an_n(ArrRayInfo_fLengthRemaining(rayStack), 0, h_broadcast_f(False, 1000.0))
	array_set_t_an_n(ArrRayInfo_fRefractiveIndex(rayStack), 0, h_broadcast_f(False, 1.0))
	array_set_t_an3_n(ArrRayInfo_vAmount(rayStack), 0, h_broadcast_f3(False, swizzle_n_xxx(1.0)))
	array_set_t_an_n(ArrRayInfo_iChild0(rayStack), 0, h_broadcast_i(False, -1))
	array_set_t_an_n(ArrRayInfo_iChild1(rayStack), 0, h_broadcast_i(False, -1))
	refractRayInfo = t_RayInfo_defval(True)
	reflectRayInfo = t_RayInfo_defval(True)
	_br_flag_34 = h_broadcast_b(False, False)
	_cont_flag_34 = h_broadcast_b(False, False)
	iPassIndex = 0
	while True:
		try:
			_vecif_53_exp_0 = h_not_t_n(_br_flag_34)
			if any_ifexp_true_t_n(_vecif_53_exp_0):
				_vecif_53_refractRayInfo = h_copy_t_RayInfo(refractRayInfo)
				_vecif_53_reflectRayInfo = h_copy_t_RayInfo(reflectRayInfo)
				_vecif_53__cont_flag_34 = _cont_flag_34
				_vecif_53__br_flag_34 = _br_flag_34
				_vecif_53_stackCurrent = stackCurrent
				_vecif_53_rayStack = rayStack
				_vecif_53_ix = ix
				_vecif_53_stackEnd = stackEnd
				_vecif_53__cont_flag_34 = h_broadcast_b(False, False)
				_vecif_54_exp_0 = h_less_than_n_n(iPassIndex, 12)
				if any_ifexp_true_n(_vecif_54_exp_0):
					_vecif_54_refractRayInfo = h_copy_t_RayInfo(_vecif_53_refractRayInfo)
					_vecif_54_reflectRayInfo = h_copy_t_RayInfo(_vecif_53_reflectRayInfo)
					_vecif_54__br_flag_34 = _vecif_53__br_flag_34
					_vecif_54_stackCurrent = _vecif_53_stackCurrent
					_vecif_54__cont_flag_34 = _vecif_53__cont_flag_34
					_vecif_54_rayStack = _vecif_53_rayStack
					_vecif_54_ix = _vecif_53_ix
					_vecif_54_stackEnd = _vecif_53_stackEnd
					_vecif_55_exp = h_greater_equal_than_t_n_n(_vecif_54_ix, 12)
					if any_ifexp_true_t_n(_vecif_55_exp):
						_vecif_55__br_flag_34 = _vecif_54__br_flag_34
						_vecif_55__br_flag_34 = h_broadcast_b(False, True)
						_vecif_54__br_flag_34 = h_where_t_n_t_n_t_n(_vecif_55_exp, _vecif_55__br_flag_34, _vecif_54__br_flag_34)
					_vecif_56_exp = h_not_t_n(_vecif_54__br_flag_34)
					if any_ifexp_true_t_n(_vecif_56_exp):
						_vecif_56_refractRayInfo = h_copy_t_RayInfo(_vecif_54_refractRayInfo)
						_vecif_56_reflectRayInfo = h_copy_t_RayInfo(_vecif_54_reflectRayInfo)
						_vecif_56_stackCurrent = _vecif_54_stackCurrent
						_vecif_56__cont_flag_34 = _vecif_54__cont_flag_34
						_vecif_56_rayStack = _vecif_54_rayStack
						_vecif_56_ix = _vecif_54_ix
						_vecif_56_stackEnd = _vecif_54_stackEnd
						_vecif_56_stackCurrent = h_clamp_t_n_n_n(_vecif_56_ix, 0, 11)
						param_1 = _vecif_56_stackCurrent
						param_2 = _vecif_56_rayStack
						rayInfo = RayStack_Get_i_ArrRayInfo_arr(param_1, param_2)
						_vecif_57_exp = h_less_equal_than_t_n_n(RayInfo_fLengthRemaining(rayInfo), 0.0)
						if any_ifexp_true_t_n(_vecif_57_exp):
							_vecif_57__cont_flag_34 = _vecif_56__cont_flag_34
							_vecif_57__cont_flag_34 = h_broadcast_b(False, True)
							_vecif_56__cont_flag_34 = h_where_t_n_t_n_t_n(_vecif_57_exp, _vecif_57__cont_flag_34, _vecif_56__cont_flag_34)
						_vecif_58_exp = h_not_t_n(_vecif_56__cont_flag_34)
						if any_ifexp_true_t_n(_vecif_58_exp):
							_vecif_58_rayInfo = h_copy_t_RayInfo(rayInfo)
							_vecif_58_refractRayInfo = h_copy_t_RayInfo(_vecif_56_refractRayInfo)
							_vecif_58_reflectRayInfo = h_copy_t_RayInfo(_vecif_56_reflectRayInfo)
							_vecif_58_rayStack = _vecif_56_rayStack
							_vecif_58_ix = _vecif_56_ix
							_vecif_58_stackEnd = _vecif_56_stackEnd
							RayInfo_iChild0_set(_vecif_58_rayInfo, h_broadcast_i(False, -1))
							RayInfo_iChild1_set(_vecif_58_rayInfo, h_broadcast_i(False, -1))
							param_3 = RayInfo_fStartDist(_vecif_58_rayInfo)
							param_4 = RayInfo_fLengthRemaining(_vecif_58_rayInfo)
							param_5 = RayInfo_iObjectId(_vecif_58_rayInfo)
							traceResult = Scene_Trace_f3_f3_f_f_i_arr(RayInfo_vRayOrigin(_vecif_58_rayInfo), RayInfo_vRayDir(_vecif_58_rayInfo), param_3, param_4, param_5)
							RayInfo_fDist_set(_vecif_58_rayInfo, SceneResult_fDist(traceResult))
							RayInfo_vColor_set(_vecif_58_rayInfo, h_broadcast_f3(False, swizzle_n_xxx(0.0)))
							vReflectance = h_broadcast_f3(False, swizzle_n_xxx(1.0))
							_vecif_59_exp_0 = h_less_than_t_n_n(SceneResult_iObjectId(traceResult), 0)
							if any_ifexp_true_t_n(_vecif_59_exp_0):
								_vecif_59_rayInfo = h_copy_t_RayInfo(_vecif_58_rayInfo)
								RayInfo_vColor_set(_vecif_59_rayInfo, swizzle_t_n4_xyz(Env_GetSkyColor_f3_f3_arr(RayInfo_vRayOrigin(_vecif_59_rayInfo), RayInfo_vRayDir(_vecif_59_rayInfo))))
								_vecif_58_rayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_59_exp_0, _vecif_59_rayInfo, _vecif_58_rayInfo)
							if not_all_ifexp_true_t_n(_vecif_59_exp_0):
								_vecif_59_rayInfo = h_copy_t_RayInfo(_vecif_58_rayInfo)
								_vecif_59_refractRayInfo = h_copy_t_RayInfo(_vecif_58_refractRayInfo)
								_vecif_59_reflectRayInfo = h_copy_t_RayInfo(_vecif_58_reflectRayInfo)
								_vecif_59_vReflectance = vReflectance
								_vecif_59_rayStack = _vecif_58_rayStack
								_vecif_59_stackEnd = _vecif_58_stackEnd
								param_6 = traceResult
								param_7 = RayInfo_iObjectId(_vecif_59_rayInfo)
								surfaceInfo = Scene_GetSurfaceInfo_f3_f3_SceneResult_i_arr(RayInfo_vRayOrigin(_vecif_59_rayInfo), RayInfo_vRayDir(_vecif_59_rayInfo), param_6, param_7)
								param_8 = surfaceInfo
								surfaceLighting = Scene_GetSurfaceLighting_f3_SurfaceInfo_arr(RayInfo_vRayDir(_vecif_59_rayInfo), param_8)
								NdotV = h_clamp_t_n_n_n(h_dot_t_v_t_v(SurfaceInfo_vBumpNormal(surfaceInfo), h_sub_t_vf(RayInfo_vRayDir(_vecif_59_rayInfo))), 0.0, 1.0)
								param_9 = h_sub_t_vf(RayInfo_vRayDir(_vecif_59_rayInfo))
								param_10 = SurfaceInfo_vBumpNormal(surfaceInfo)
								param_11 = SurfaceInfo_vR0(surfaceInfo)
								param_12 = SurfaceInfo_fSmoothness(surfaceInfo)
								_vecif_59_vReflectance = Light_GetFresnel_f3_f3_f3_f_arr(param_9, param_10, param_11, param_12)
								RayInfo_vColor_set(_vecif_59_rayInfo, h_mul_t_vf_t_vf(h_add_t_vf_t_vf(h_mul_t_vf_t_vf(SurfaceInfo_vAlbedo(surfaceInfo), SurfaceLighting_vDiffuse(surfaceLighting)), SurfaceInfo_vEmissive(surfaceInfo)), h_sub_vf_t_vf(swizzle_n_xxx(1.0), _vecif_59_vReflectance)))
								vReflectAmount = _vecif_59_vReflectance
								vTranmitAmount = h_sub_vf_t_vf(swizzle_n_xxx(1.0), _vecif_59_vReflectance)
								vTranmitAmount = h_mul_t_vf_t_f(vTranmitAmount, SurfaceInfo_fTransparency(surfaceInfo))
								doReflection = h_broadcast_b(False, True)
								_vecif_60_exp = h_greater_than_t_n_n(SurfaceInfo_fTransparency(surfaceInfo), 0.0)
								if any_ifexp_true_t_n(_vecif_60_exp):
									_vecif_60_refractRayInfo = h_copy_t_RayInfo(_vecif_59_refractRayInfo)
									_vecif_60_rayInfo = h_copy_t_RayInfo(_vecif_59_rayInfo)
									_vecif_60_rayStack = _vecif_59_rayStack
									_vecif_60_stackEnd = _vecif_59_stackEnd
									_vecif_60_doReflection = doReflection
									_vecif_60_vReflectAmount = vReflectAmount
									vTestAmount = h_mul_t_vf_t_vf(vTranmitAmount, RayInfo_vAmount(_vecif_60_rayInfo))
									_vecif_61_exp = h_greater_than_t_n_n(h_add_t_f_t_f(h_add_t_f_t_f(swizzle_t_n3_x(vTestAmount), swizzle_t_n3_y(vTestAmount)), swizzle_t_n3_z(vTestAmount)), 0.00999999977)
									if any_ifexp_true_t_n(_vecif_61_exp):
										_vecif_61_refractRayInfo = h_copy_t_RayInfo(_vecif_60_refractRayInfo)
										_vecif_61_rayInfo = h_copy_t_RayInfo(_vecif_60_rayInfo)
										_vecif_61_rayStack = _vecif_60_rayStack
										_vecif_61_stackEnd = _vecif_60_stackEnd
										_vecif_61_doReflection = _vecif_60_doReflection
										_vecif_61_vReflectAmount = _vecif_60_vReflectAmount
										RayInfo_vAmount_set(_vecif_61_refractRayInfo, h_copy_t_f3(vTranmitAmount))
										RayInfo_vRayOrigin_set(_vecif_61_refractRayInfo, h_copy_t_f3(SurfaceInfo_vPos(surfaceInfo)))
										RayInfo_iObjectId_set(_vecif_61_refractRayInfo, SceneResult_iObjectId(traceResult))
										RayInfo_vRayDir_set(_vecif_61_refractRayInfo, h_refract_t_v_t_v_t_n(RayInfo_vRayDir(_vecif_61_rayInfo), SurfaceInfo_vBumpNormal(surfaceInfo), h_div_t_f_t_f(RayInfo_fRefractiveIndex(_vecif_61_rayInfo), SurfaceInfo_fRefractiveIndex(surfaceInfo))))
										_vecif_62_exp = h_equal_t_n_t_n(SceneResult_iObjectId(traceResult), RayInfo_iObjectId(_vecif_61_rayInfo))
										if any_ifexp_true_t_n(_vecif_62_exp):
											_vecif_62_refractRayInfo = h_copy_t_RayInfo(_vecif_61_refractRayInfo)
											RayInfo_iObjectId_set(_vecif_62_refractRayInfo, h_broadcast_i(False, -1))
											_vecif_61_refractRayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_62_exp, _vecif_62_refractRayInfo, _vecif_61_refractRayInfo)
										_vecif_63_exp_0 = h_greater_than_t_n_n(h_length_t_v(RayInfo_vRayDir(_vecif_61_refractRayInfo)), 0.0)
										if any_ifexp_true_t_n(_vecif_63_exp_0):
											_vecif_63_refractRayInfo = h_copy_t_RayInfo(_vecif_61_refractRayInfo)
											_vecif_63_rayInfo = h_copy_t_RayInfo(_vecif_61_rayInfo)
											_vecif_63_rayStack = _vecif_61_rayStack
											_vecif_63_stackEnd = _vecif_61_stackEnd
											_vecif_63_doReflection = _vecif_61_doReflection
											RayInfo_vRayDir_set(_vecif_63_refractRayInfo, h_normalize_t_v(RayInfo_vRayDir(_vecif_63_refractRayInfo)))
											RayInfo_fStartDist_set(_vecif_63_refractRayInfo, h_abs_t_n(h_div_f_t_f(0.100000001, h_dot_t_v_t_v(RayInfo_vRayDir(_vecif_63_refractRayInfo), SurfaceInfo_vNormal(surfaceInfo)))))
											RayInfo_fLengthRemaining_set(_vecif_63_refractRayInfo, h_sub_t_f_t_f(RayInfo_fLengthRemaining(_vecif_63_rayInfo), SceneResult_fDist(traceResult)))
											RayInfo_fDist_set(_vecif_63_refractRayInfo, h_sub_f_t_f(1.0, RayInfo_fDist(_vecif_63_rayInfo)))
											RayInfo_fRefractiveIndex_set(_vecif_63_refractRayInfo, SurfaceInfo_fRefractiveIndex(surfaceInfo))
											RayInfo_iChild1_set(_vecif_63_rayInfo, h_copy_t_i(_vecif_63_stackEnd))
											RayInfo_vColor_set(_vecif_63_rayInfo, h_mul_t_vf_t_f(RayInfo_vColor(_vecif_63_rayInfo), h_sub_f_t_f(1.0, SurfaceInfo_fTransparency(surfaceInfo))))
											RayInfo_vAmount_set(_vecif_63_refractRayInfo, h_mul_t_vf_t_f(RayInfo_vAmount(_vecif_63_refractRayInfo), SurfaceInfo_fTransparency(surfaceInfo)))
											param_13 = _vecif_63_stackEnd
											param_14 = h_copy_t_RayInfo(_vecif_63_refractRayInfo)
											param_15 = _vecif_63_rayStack
											param_15 = RayStack_Set_i_RayInfo_ArrRayInfo_arr(param_13, param_14, h_copy_t_ArrRayInfo(param_15))
											_vecif_63_rayStack = param_15
											_vecif_63_stackEnd = h_inc_t_i(_vecif_63_stackEnd)
											_vecif_63_stackEnd = h_clamp_t_n_n_n(_vecif_63_stackEnd, 0, 11)
											_vecif_63_doReflection = h_broadcast_b(False, False)
											_vecif_61_refractRayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_63_exp_0, _vecif_63_refractRayInfo, _vecif_61_refractRayInfo)
											_vecif_61_rayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_63_exp_0, _vecif_63_rayInfo, _vecif_61_rayInfo)
											_vecif_61_rayStack = h_where_t_n_t_ArrRayInfo_t_ArrRayInfo(_vecif_63_exp_0, _vecif_63_rayStack, _vecif_61_rayStack)
											_vecif_61_stackEnd = h_where_t_n_t_n_t_n(_vecif_63_exp_0, _vecif_63_stackEnd, _vecif_61_stackEnd)
											_vecif_61_doReflection = h_where_t_n_t_n_t_n(_vecif_63_exp_0, _vecif_63_doReflection, _vecif_61_doReflection)
										if not_all_ifexp_true_t_n(_vecif_63_exp_0):
											_vecif_63_vReflectAmount = _vecif_61_vReflectAmount
											_vecif_63_vReflectAmount = h_add_t_vf_t_vf(_vecif_63_vReflectAmount, vTranmitAmount)
											#condition: not _vecif_63_exp_0
											_vecif_61_vReflectAmount = h_where_t_n_t_v_t_v(_vecif_63_exp_0, _vecif_61_vReflectAmount, _vecif_63_vReflectAmount)
										_vecif_60_refractRayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_61_exp, _vecif_61_refractRayInfo, _vecif_60_refractRayInfo)
										_vecif_60_rayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_61_exp, _vecif_61_rayInfo, _vecif_60_rayInfo)
										_vecif_60_rayStack = h_where_t_n_t_ArrRayInfo_t_ArrRayInfo(_vecif_61_exp, _vecif_61_rayStack, _vecif_60_rayStack)
										_vecif_60_stackEnd = h_where_t_n_t_n_t_n(_vecif_61_exp, _vecif_61_stackEnd, _vecif_60_stackEnd)
										_vecif_60_doReflection = h_where_t_n_t_n_t_n(_vecif_61_exp, _vecif_61_doReflection, _vecif_60_doReflection)
										_vecif_60_vReflectAmount = h_where_t_n_t_v_t_v(_vecif_61_exp, _vecif_61_vReflectAmount, _vecif_60_vReflectAmount)
									_vecif_59_refractRayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_60_exp, _vecif_60_refractRayInfo, _vecif_59_refractRayInfo)
									_vecif_59_rayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_60_exp, _vecif_60_rayInfo, _vecif_59_rayInfo)
									_vecif_59_rayStack = h_where_t_n_t_ArrRayInfo_t_ArrRayInfo(_vecif_60_exp, _vecif_60_rayStack, _vecif_59_rayStack)
									_vecif_59_stackEnd = h_where_t_n_t_n_t_n(_vecif_60_exp, _vecif_60_stackEnd, _vecif_59_stackEnd)
									doReflection = h_where_t_n_t_n_t_n(_vecif_60_exp, _vecif_60_doReflection, doReflection)
									vReflectAmount = h_where_t_n_t_v_t_v(_vecif_60_exp, _vecif_60_vReflectAmount, vReflectAmount)
								_vecif_64_exp = doReflection
								if any_ifexp_true_t_n(_vecif_64_exp):
									_vecif_64_reflectRayInfo = h_copy_t_RayInfo(_vecif_59_reflectRayInfo)
									_vecif_64_rayInfo = h_copy_t_RayInfo(_vecif_59_rayInfo)
									_vecif_64_rayStack = _vecif_59_rayStack
									_vecif_64_stackEnd = _vecif_59_stackEnd
									vTestAmount_1 = h_mul_t_vf_t_vf(vReflectAmount, RayInfo_vAmount(_vecif_64_rayInfo))
									_vecif_65_exp = h_greater_than_t_n_n(h_add_t_f_t_f(h_add_t_f_t_f(swizzle_t_n3_x(vTestAmount_1), swizzle_t_n3_y(vTestAmount_1)), swizzle_t_n3_z(vTestAmount_1)), 0.00999999977)
									if any_ifexp_true_t_n(_vecif_65_exp):
										_vecif_65_reflectRayInfo = h_copy_t_RayInfo(_vecif_64_reflectRayInfo)
										_vecif_65_rayInfo = h_copy_t_RayInfo(_vecif_64_rayInfo)
										_vecif_65_rayStack = _vecif_64_rayStack
										_vecif_65_stackEnd = _vecif_64_stackEnd
										RayInfo_vAmount_set(_vecif_65_reflectRayInfo, h_copy_t_f3(vReflectAmount))
										RayInfo_vRayOrigin_set(_vecif_65_reflectRayInfo, h_copy_t_f3(SurfaceInfo_vPos(surfaceInfo)))
										RayInfo_vRayDir_set(_vecif_65_reflectRayInfo, h_normalize_t_v(h_reflect_t_v_t_v(RayInfo_vRayDir(_vecif_65_rayInfo), SurfaceInfo_vBumpNormal(surfaceInfo))))
										RayInfo_iObjectId_set(_vecif_65_reflectRayInfo, RayInfo_iObjectId(_vecif_65_rayInfo))
										RayInfo_fStartDist_set(_vecif_65_reflectRayInfo, h_abs_t_n(h_div_f_t_f(0.00999999977, h_dot_t_v_t_v(RayInfo_vRayDir(_vecif_65_reflectRayInfo), SurfaceInfo_vNormal(surfaceInfo)))))
										RayInfo_fLengthRemaining_set(_vecif_65_reflectRayInfo, h_sub_t_f_t_f(RayInfo_fLengthRemaining(_vecif_65_rayInfo), SceneResult_fDist(traceResult)))
										RayInfo_fRefractiveIndex_set(_vecif_65_reflectRayInfo, RayInfo_fRefractiveIndex(_vecif_65_rayInfo))
										RayInfo_iChild0_set(_vecif_65_rayInfo, h_copy_t_i(_vecif_65_stackEnd))
										param_16 = _vecif_65_stackEnd
										param_17 = h_copy_t_RayInfo(_vecif_65_reflectRayInfo)
										param_18 = _vecif_65_rayStack
										param_18 = RayStack_Set_i_RayInfo_ArrRayInfo_arr(param_16, param_17, h_copy_t_ArrRayInfo(param_18))
										_vecif_65_rayStack = param_18
										_vecif_65_stackEnd = h_inc_t_i(_vecif_65_stackEnd)
										_vecif_65_stackEnd = h_clamp_t_n_n_n(_vecif_65_stackEnd, 0, 11)
										_vecif_64_reflectRayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_65_exp, _vecif_65_reflectRayInfo, _vecif_64_reflectRayInfo)
										_vecif_64_rayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_65_exp, _vecif_65_rayInfo, _vecif_64_rayInfo)
										_vecif_64_rayStack = h_where_t_n_t_ArrRayInfo_t_ArrRayInfo(_vecif_65_exp, _vecif_65_rayStack, _vecif_64_rayStack)
										_vecif_64_stackEnd = h_where_t_n_t_n_t_n(_vecif_65_exp, _vecif_65_stackEnd, _vecif_64_stackEnd)
									_vecif_59_reflectRayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_64_exp, _vecif_64_reflectRayInfo, _vecif_59_reflectRayInfo)
									_vecif_59_rayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_64_exp, _vecif_64_rayInfo, _vecif_59_rayInfo)
									_vecif_59_rayStack = h_where_t_n_t_ArrRayInfo_t_ArrRayInfo(_vecif_64_exp, _vecif_64_rayStack, _vecif_59_rayStack)
									_vecif_59_stackEnd = h_where_t_n_t_n_t_n(_vecif_64_exp, _vecif_64_stackEnd, _vecif_59_stackEnd)
								RayInfo_vColor_set(_vecif_59_rayInfo, h_add_t_vf_t_vf(RayInfo_vColor(_vecif_59_rayInfo), h_mul_t_vf_t_vf(SurfaceLighting_vSpecular(surfaceLighting), _vecif_59_vReflectance)))
								#condition: not _vecif_59_exp_0
								_vecif_58_rayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_59_exp_0, _vecif_58_rayInfo, _vecif_59_rayInfo)
								#condition: not _vecif_59_exp_0
								_vecif_58_refractRayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_59_exp_0, _vecif_58_refractRayInfo, _vecif_59_refractRayInfo)
								#condition: not _vecif_59_exp_0
								_vecif_58_reflectRayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_59_exp_0, _vecif_58_reflectRayInfo, _vecif_59_reflectRayInfo)
								#condition: not _vecif_59_exp_0
								vReflectance = h_where_t_n_t_v_t_v(_vecif_59_exp_0, vReflectance, _vecif_59_vReflectance)
								#condition: not _vecif_59_exp_0
								_vecif_58_rayStack = h_where_t_n_t_ArrRayInfo_t_ArrRayInfo(_vecif_59_exp_0, _vecif_58_rayStack, _vecif_59_rayStack)
								#condition: not _vecif_59_exp_0
								_vecif_58_stackEnd = h_where_t_n_t_n_t_n(_vecif_59_exp_0, _vecif_58_stackEnd, _vecif_59_stackEnd)
							param_19 = _vecif_56_stackCurrent
							param_20 = h_copy_t_RayInfo(_vecif_58_rayInfo)
							param_21 = _vecif_58_rayStack
							param_21 = RayStack_Set_i_RayInfo_ArrRayInfo_arr(param_19, param_20, h_copy_t_ArrRayInfo(param_21))
							_vecif_58_rayStack = param_21
							_vecif_58_ix = h_inc_t_i(_vecif_58_ix)
							rayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_58_exp, _vecif_58_rayInfo, rayInfo)
							_vecif_56_refractRayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_58_exp, _vecif_58_refractRayInfo, _vecif_56_refractRayInfo)
							_vecif_56_reflectRayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_58_exp, _vecif_58_reflectRayInfo, _vecif_56_reflectRayInfo)
							_vecif_56_rayStack = h_where_t_n_t_ArrRayInfo_t_ArrRayInfo(_vecif_58_exp, _vecif_58_rayStack, _vecif_56_rayStack)
							_vecif_56_ix = h_where_t_n_t_n_t_n(_vecif_58_exp, _vecif_58_ix, _vecif_56_ix)
							_vecif_56_stackEnd = h_where_t_n_t_n_t_n(_vecif_58_exp, _vecif_58_stackEnd, _vecif_56_stackEnd)
						_vecif_54_refractRayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_56_exp, _vecif_56_refractRayInfo, _vecif_54_refractRayInfo)
						_vecif_54_reflectRayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_56_exp, _vecif_56_reflectRayInfo, _vecif_54_reflectRayInfo)
						_vecif_54_stackCurrent = h_where_t_n_t_n_t_n(_vecif_56_exp, _vecif_56_stackCurrent, _vecif_54_stackCurrent)
						_vecif_54__cont_flag_34 = h_where_t_n_t_n_t_n(_vecif_56_exp, _vecif_56__cont_flag_34, _vecif_54__cont_flag_34)
						_vecif_54_rayStack = h_where_t_n_t_ArrRayInfo_t_ArrRayInfo(_vecif_56_exp, _vecif_56_rayStack, _vecif_54_rayStack)
						_vecif_54_ix = h_where_t_n_t_n_t_n(_vecif_56_exp, _vecif_56_ix, _vecif_54_ix)
						_vecif_54_stackEnd = h_where_t_n_t_n_t_n(_vecif_56_exp, _vecif_56_stackEnd, _vecif_54_stackEnd)
					_vecif_53_refractRayInfo = h_where_n_t_RayInfo_t_RayInfo(_vecif_54_exp_0, _vecif_54_refractRayInfo, _vecif_53_refractRayInfo)
					_vecif_53_reflectRayInfo = h_where_n_t_RayInfo_t_RayInfo(_vecif_54_exp_0, _vecif_54_reflectRayInfo, _vecif_53_reflectRayInfo)
					_vecif_53__br_flag_34 = h_where_n_t_n_t_n(_vecif_54_exp_0, _vecif_54__br_flag_34, _vecif_53__br_flag_34)
					_vecif_53_stackCurrent = h_where_n_t_n_t_n(_vecif_54_exp_0, _vecif_54_stackCurrent, _vecif_53_stackCurrent)
					_vecif_53__cont_flag_34 = h_where_n_t_n_t_n(_vecif_54_exp_0, _vecif_54__cont_flag_34, _vecif_53__cont_flag_34)
					_vecif_53_rayStack = h_where_n_t_ArrRayInfo_t_ArrRayInfo(_vecif_54_exp_0, _vecif_54_rayStack, _vecif_53_rayStack)
					_vecif_53_ix = h_where_n_t_n_t_n(_vecif_54_exp_0, _vecif_54_ix, _vecif_53_ix)
					_vecif_53_stackEnd = h_where_n_t_n_t_n(_vecif_54_exp_0, _vecif_54_stackEnd, _vecif_53_stackEnd)
				if not_any_ifexp_true_n(_vecif_54_exp_0):
					_vecif_54__br_flag_34 = _vecif_53__br_flag_34
					_vecif_54__br_flag_34 = h_broadcast_b(False, True)
					#condition: not _vecif_54_exp_0
					_vecif_53__br_flag_34 = h_where_n_t_n_t_n(_vecif_54_exp_0, _vecif_53__br_flag_34, _vecif_54__br_flag_34)
				refractRayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_53_exp_0, _vecif_53_refractRayInfo, refractRayInfo)
				reflectRayInfo = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_53_exp_0, _vecif_53_reflectRayInfo, reflectRayInfo)
				_cont_flag_34 = h_where_t_n_t_n_t_n(_vecif_53_exp_0, _vecif_53__cont_flag_34, _cont_flag_34)
				_br_flag_34 = h_where_t_n_t_n_t_n(_vecif_53_exp_0, _vecif_53__br_flag_34, _br_flag_34)
				stackCurrent = h_where_t_n_t_n_t_n(_vecif_53_exp_0, _vecif_53_stackCurrent, stackCurrent)
				rayStack = h_where_t_n_t_ArrRayInfo_t_ArrRayInfo(_vecif_53_exp_0, _vecif_53_rayStack, rayStack)
				ix = h_where_t_n_t_n_t_n(_vecif_53_exp_0, _vecif_53_ix, ix)
				stackEnd = h_where_t_n_t_n_t_n(_vecif_53_exp_0, _vecif_53_stackEnd, stackEnd)
			if not_any_ifexp_true_t_n(_vecif_53_exp_0):
				break
		finally:
			iPassIndex = h_inc_i(iPassIndex)
	_br_flag_35 = False
	_cont_flag_35 = h_broadcast_b(False, False)
	iStackPos = 11
	while True:
		try:
			_vecif_66_exp_0 = h_not_n(_br_flag_35)
			if any_ifexp_true_n(_vecif_66_exp_0):
				_vecif_66__cont_flag_35 = _cont_flag_35
				_vecif_66__br_flag_35 = _br_flag_35
				_vecif_66_rayStack = rayStack
				_vecif_66__cont_flag_35 = h_broadcast_b(False, False)
				_vecif_67_exp_0 = h_greater_equal_than_n_n(iStackPos, 0)
				if any_ifexp_true_n(_vecif_67_exp_0):
					_vecif_67__cont_flag_35 = _vecif_66__cont_flag_35
					_vecif_67_rayStack = _vecif_66_rayStack
					param_22 = iStackPos
					param_23 = _vecif_67_rayStack
					rayInfo_1 = RayStack_Get_i_ArrRayInfo_arr1(param_22, param_23)
					_vecif_68_exp = h_less_equal_than_t_n_n(RayInfo_fLengthRemaining(rayInfo_1), 0.0)
					if any_ifexp_true_t_n(_vecif_68_exp):
						_vecif_68__cont_flag_35 = _vecif_67__cont_flag_35
						_vecif_68__cont_flag_35 = h_broadcast_b(False, True)
						_vecif_67__cont_flag_35 = h_where_t_n_t_n_t_n(_vecif_68_exp, _vecif_68__cont_flag_35, _vecif_67__cont_flag_35)
					_vecif_69_exp = h_not_t_n(_vecif_67__cont_flag_35)
					if any_ifexp_true_t_n(_vecif_69_exp):
						_vecif_69_rayInfo_1 = h_copy_t_RayInfo(rayInfo_1)
						_vecif_69_rayStack = _vecif_67_rayStack
						_vecif_70_exp = h_greater_equal_than_t_n_n(RayInfo_iChild0(_vecif_69_rayInfo_1), 0)
						if any_ifexp_true_t_n(_vecif_70_exp):
							_vecif_70_rayInfo_1 = h_copy_t_RayInfo(_vecif_69_rayInfo_1)
							param_24 = RayInfo_iChild0(_vecif_70_rayInfo_1)
							param_25 = _vecif_69_rayStack
							childRayInfo = RayStack_Get_i_ArrRayInfo_arr(param_24, param_25)
							_vecif_71_exp = h_greater_than_t_n_n(RayInfo_fDist(childRayInfo), 0.0)
							if any_ifexp_true_t_n(_vecif_71_exp):
								_vecif_71_rayInfo_1 = h_copy_t_RayInfo(_vecif_70_rayInfo_1)
								RayInfo_vColor_set(_vecif_71_rayInfo_1, h_add_t_vf_t_vf(RayInfo_vColor(_vecif_71_rayInfo_1), h_mul_t_vf_t_vf(RayInfo_vAmount(childRayInfo), RayInfo_vColor(childRayInfo))))
								_vecif_70_rayInfo_1 = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_71_exp, _vecif_71_rayInfo_1, _vecif_70_rayInfo_1)
							_vecif_69_rayInfo_1 = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_70_exp, _vecif_70_rayInfo_1, _vecif_69_rayInfo_1)
						_vecif_72_exp = h_greater_equal_than_t_n_n(RayInfo_iChild1(_vecif_69_rayInfo_1), 0)
						if any_ifexp_true_t_n(_vecif_72_exp):
							_vecif_72_rayInfo_1 = h_copy_t_RayInfo(_vecif_69_rayInfo_1)
							param_26 = RayInfo_iChild1(_vecif_72_rayInfo_1)
							param_27 = _vecif_69_rayStack
							childRayInfo_1 = RayStack_Get_i_ArrRayInfo_arr(param_26, param_27)
							_vecif_73_exp = h_greater_than_t_n_n(RayInfo_fDist(childRayInfo_1), 0.0)
							if any_ifexp_true_t_n(_vecif_73_exp):
								_vecif_73_rayInfo_1 = h_copy_t_RayInfo(_vecif_72_rayInfo_1)
								RayInfo_vColor_set(_vecif_73_rayInfo_1, h_add_t_vf_t_vf(RayInfo_vColor(_vecif_73_rayInfo_1), h_mul_t_vf_t_vf(RayInfo_vAmount(childRayInfo_1), RayInfo_vColor(childRayInfo_1))))
								_vecif_72_rayInfo_1 = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_73_exp, _vecif_73_rayInfo_1, _vecif_72_rayInfo_1)
							_vecif_69_rayInfo_1 = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_72_exp, _vecif_72_rayInfo_1, _vecif_69_rayInfo_1)
						RayInfo_vColor_set(_vecif_69_rayInfo_1, Env_ApplyAtmosphere_f3_f3_f3_f_i_arr(RayInfo_vColor(_vecif_69_rayInfo_1), RayInfo_vRayOrigin(_vecif_69_rayInfo_1), RayInfo_vRayDir(_vecif_69_rayInfo_1), RayInfo_fDist(_vecif_69_rayInfo_1), RayInfo_iObjectId(_vecif_69_rayInfo_1)))
						param_28 = RayInfo_vColor(_vecif_69_rayInfo_1)
						RayInfo_vColor_set(_vecif_69_rayInfo_1, FX_Apply_f3_f3_f3_f_arr(param_28, RayInfo_vRayOrigin(_vecif_69_rayInfo_1), RayInfo_vRayDir(_vecif_69_rayInfo_1), RayInfo_fDist(_vecif_69_rayInfo_1)))
						param_29 = iStackPos
						param_30 = h_copy_t_RayInfo(_vecif_69_rayInfo_1)
						param_31 = _vecif_69_rayStack
						param_31 = RayStack_Set_i_RayInfo_ArrRayInfo_arr1(param_29, param_30, h_copy_t_ArrRayInfo(param_31))
						_vecif_69_rayStack = param_31
						rayInfo_1 = h_where_t_n_t_RayInfo_t_RayInfo(_vecif_69_exp, _vecif_69_rayInfo_1, rayInfo_1)
						_vecif_67_rayStack = h_where_t_n_t_ArrRayInfo_t_ArrRayInfo(_vecif_69_exp, _vecif_69_rayStack, _vecif_67_rayStack)
					_vecif_66__cont_flag_35 = h_where_n_t_n_t_n(_vecif_67_exp_0, _vecif_67__cont_flag_35, _vecif_66__cont_flag_35)
					_vecif_66_rayStack = h_where_n_t_ArrRayInfo_t_ArrRayInfo(_vecif_67_exp_0, _vecif_67_rayStack, _vecif_66_rayStack)
				if not_any_ifexp_true_n(_vecif_67_exp_0):
					_vecif_67__br_flag_35 = _vecif_66__br_flag_35
					_vecif_67__br_flag_35 = True
					#condition: not _vecif_67_exp_0
					_vecif_66__br_flag_35 = h_where_n_n_n(_vecif_67_exp_0, _vecif_66__br_flag_35, _vecif_67__br_flag_35)
				_cont_flag_35 = h_where_n_t_n_t_n(_vecif_66_exp_0, _vecif_66__cont_flag_35, _cont_flag_35)
				_br_flag_35 = h_where_n_n_n(_vecif_66_exp_0, _vecif_66__br_flag_35, _br_flag_35)
				rayStack = h_where_n_t_ArrRayInfo_t_ArrRayInfo(_vecif_66_exp_0, _vecif_66_rayStack, rayStack)
			if not_any_ifexp_true_n(_vecif_66_exp_0):
				break
		finally:
			iStackPos = h_dec_i(iStackPos)
	firstTraceResult = SceneResult_defval()
	_vecif_74_exp = h_greater_equal_than_n_n(SceneResult_iObjectId(firstTraceResult), 10)
	if any_ifexp_true_n(_vecif_74_exp):
		_vecif_74_firstTraceResult = h_copy_SceneResult(firstTraceResult)
		SceneResult_fDist_set(_vecif_74_firstTraceResult, h_sub_f(SceneResult_fDist(_vecif_74_firstTraceResult)))
		firstTraceResult = h_where_n_SceneResult_SceneResult(_vecif_74_exp, _vecif_74_firstTraceResult, firstTraceResult)
	return h_t_f4_t_n3_t_n(array_get_t_an3_n(ArrRayInfo_vColor(rayStack), 0), array_get_t_an_n(ArrRayInfo_fDist(rayStack), 0))

def Cam_GetViewCoordFromUV_f2_arr(vUV):
	global iResolution
	vWindow = h_sub_t_vf_vf(h_mul_t_vf_f(vUV, 2.0), swizzle_n_xx(1.0))
	swizzle_set_t_n2_x(vWindow, h_mul_t_f_f(swizzle_t_n2_x(vWindow), h_div_f_f(swizzle_n3_x(iResolution), swizzle_n3_y(iResolution))))
	return vWindow

def Tonemap_f3_arr(x):
	a = 0.00999999977
	b = 0.131999999
	c = 0.00999999977
	d = 0.163000003
	e = 0.101000004
	return h_div_t_vf_t_vf(h_mul_t_vf_t_vf(x, h_add_t_vf_vf(h_mul_t_vf_f(x, 0.00999999977), swizzle_n_xxx(b))), h_add_t_vf_vf(h_mul_t_vf_t_vf(x, h_add_t_vf_vf(h_mul_t_vf_f(x, 0.00999999977), swizzle_n_xxx(d))), swizzle_n_xxx(e)))

def ColorGrade_f3_arr(vColor):
	vHue = h_f3_n_n_n(1.0, 0.699999988, 0.200000003)
	vGamma = h_add_vf_vf(swizzle_n_xxx(1.0), h_mul_vf_f(vHue, 0.600000024))
	vGain = h_add_vf_vf(swizzle_n_xxx(0.899999976), h_mul_vf_f(h_mul_vf_vf(vHue, vHue), 8.0))
	vColor = h_mul_t_vf_f(vColor, 2.0)
	fMaxLum = 100.0
	vColor = h_div_t_vf_vf(vColor, swizzle_n_xxx(fMaxLum))
	vColor = h_pow_t_v_v(vColor, vGamma)
	vColor = h_mul_t_vf_vf(vColor, vGain)
	vColor = h_mul_t_vf_f(vColor, 100.0)
	return vColor, vColor

def MainCommon_f3_f3_f_arr(vRayOrigin, vRayDir, fShade):
	global fPlaneInFocus
	vColorLinAmdDepth = Scene_GetColorAndDepth_f3_f3_arr(vRayOrigin, vRayDir)
	_2024 = h_copy_t_f4(vColorLinAmdDepth)
	_2026 = h_max_t_v_v(swizzle_t_n4_xyz(_2024), swizzle_n_xxx(0.0))
	swizzle_set_t_n4_x(vColorLinAmdDepth, swizzle_t_n3_x(_2026))
	swizzle_set_t_n4_y(vColorLinAmdDepth, swizzle_t_n3_y(_2026))
	swizzle_set_t_n4_z(vColorLinAmdDepth, swizzle_t_n3_z(_2026))
	vFragColor = h_copy_t_f4(vColorLinAmdDepth)
	_2036 = h_copy_t_f4(vFragColor)
	_2038 = h_mul_t_vf_t_f(swizzle_t_n4_xyz(_2036), fShade)
	swizzle_set_t_n4_x(vFragColor, swizzle_t_n3_x(_2038))
	swizzle_set_t_n4_y(vFragColor, swizzle_t_n3_y(_2038))
	swizzle_set_t_n4_z(vFragColor, swizzle_t_n3_z(_2038))
	param = swizzle_t_n4_w(vColorLinAmdDepth)
	param_1 = fPlaneInFocus
	swizzle_set_t_n4_w(vFragColor, GetCoC_f_f_arr(param, param_1))
	return vFragColor

def GetVignetting_f2_f_f_f_arr(vUV, fScale, fPower, fStrength):
	vOffset = h_mul_t_vf_f(h_mul_t_vf_f(h_sub_t_vf_vf(vUV, swizzle_n_xx(0.5)), 1.41421354), fScale)
	fDist = h_max_n_t_n(0.0, h_sub_f_t_f(1.0, h_length_t_v(vOffset)))
	fShade = h_sub_f_t_f(1.0, h_pow_t_n_n(fDist, fPower))
	fShade = h_sub_f_t_f(1.0, h_mul_t_f_f(fShade, fStrength))
	return fShade

def Cam_GetCameraRay_f2_CameraState_f3_f3_arr(vUV, cam, vRayOrigin, vRayDir):
	vView = Cam_GetViewCoordFromUV_f2_arr(vUV)
	vRayOrigin = h_broadcast_f3(False, CameraState_vPos(cam))
	fPerspDist = h_div_f_f(1.0, h_tan_n(h_radians_n(CameraState_fFov(cam))))
	vRayDir = h_normalize_t_v(h_matmul_t_f3_f3x3(h_t_f3_t_n2_n(vView, fPerspDist), Cam_GetWorldToCameraRotMatrix_CameraState(cam)))
	return vRayOrigin, vRayDir

def mainImage_f4_f2_arr(fragColor, fragCoord):
	global iResolution, iChannel0, _iChannel0_sampler, fGolden
	vUV = h_div_t_vf_vf(fragCoord, swizzle_n3_xy(iResolution))
	vSample = Texture2D__float4_T_SampleLevel_n_t_v_n(iChannel0, _iChannel0_sampler, vUV, 0.0)
	fCoC = swizzle_t_n4_w(vSample)
	vResult = swizzle_t_n4_xyz(vSample)
	fTot = h_broadcast_f(False, 0.0)
	vangle = h_t_f2_n_t_n(0.0, fCoC)
	_vecif_49_exp = h_greater_than_t_n_n(h_abs_t_n(fCoC), 0.0)
	if any_ifexp_true_t_n(_vecif_49_exp):
		_vecif_49_vResult = vResult
		_vecif_49_fTot = fTot
		_vecif_49_vResult = h_mul_t_vf_t_f(_vecif_49_vResult, fCoC)
		_vecif_49_fTot = h_add_t_f_t_f(_vecif_49_fTot, fCoC)
		fBlurTaps = 32.0
		_br_flag_42 = False
		i = 1
		while True:
			try:
				_vecif_50_exp_0 = h_not_n(_br_flag_42)
				if any_ifexp_true_n(_vecif_50_exp_0):
					_vecif_50_vResult = _vecif_49_vResult
					_vecif_50_fTot = _vecif_49_fTot
					_vecif_50__br_flag_42 = _br_flag_42
					_vecif_51_exp_0 = h_less_than_n_n(i, 32)
					if any_ifexp_true_n(_vecif_51_exp_0):
						_vecif_51_vResult = _vecif_50_vResult
						_vecif_51_fTot = _vecif_50_fTot
						t = h_div_f_f(h_cast_f_i(i), fBlurTaps)
						fTheta = h_mul_f_f(h_mul_f_f(t, fBlurTaps), fGolden)
						fRadius = h_div_t_f_f(h_mul_t_f_f(fCoC, h_sqrt_n(h_mul_f_f(t, fBlurTaps))), h_sqrt_n(fBlurTaps))
						vTapUV = h_add_t_vf_t_vf(vUV, h_mul_vf_t_f(h_f2_n_n(h_sin_n(fTheta), h_cos_n(fTheta)), fRadius))
						vTapSample = Texture2D__float4_T_SampleLevel_n_t_v_n(iChannel0, _iChannel0_sampler, vTapUV, 0.0)
						fCoC2 = swizzle_t_n4_w(vTapSample)
						fWeight = h_max_n_t_n(0.00100000005, fCoC2)
						_vecif_51_vResult = h_add_t_vf_t_vf(_vecif_51_vResult, h_mul_t_vf_t_f(swizzle_t_n4_xyz(vTapSample), fWeight))
						_vecif_51_fTot = h_add_t_f_t_f(_vecif_51_fTot, fWeight)
						_vecif_50_vResult = h_where_n_t_v_t_v(_vecif_51_exp_0, _vecif_51_vResult, _vecif_50_vResult)
						_vecif_50_fTot = h_where_n_t_n_t_n(_vecif_51_exp_0, _vecif_51_fTot, _vecif_50_fTot)
					if not_any_ifexp_true_n(_vecif_51_exp_0):
						_vecif_51__br_flag_42 = _vecif_50__br_flag_42
						_vecif_51__br_flag_42 = True
						#condition: not _vecif_51_exp_0
						_vecif_50__br_flag_42 = h_where_n_n_n(_vecif_51_exp_0, _vecif_50__br_flag_42, _vecif_51__br_flag_42)
					_vecif_49_vResult = h_where_n_t_v_t_v(_vecif_50_exp_0, _vecif_50_vResult, _vecif_49_vResult)
					_vecif_49_fTot = h_where_n_t_n_t_n(_vecif_50_exp_0, _vecif_50_fTot, _vecif_49_fTot)
					_br_flag_42 = h_where_n_n_n(_vecif_50_exp_0, _vecif_50__br_flag_42, _br_flag_42)
				if not_any_ifexp_true_n(_vecif_50_exp_0):
					break
			finally:
				i = h_inc_i(i)
		_vecif_49_vResult = h_div_t_vf_t_vf(_vecif_49_vResult, swizzle_t_n_xxx(_vecif_49_fTot))
		vResult = h_where_t_n_t_v_t_v(_vecif_49_exp, _vecif_49_vResult, vResult)
		fTot = h_where_t_n_t_n_t_n(_vecif_49_exp, _vecif_49_fTot, fTot)
	fragColor = h_t_f4_t_n3_n(vResult, 1.0)
	fExposure = 3.0
	_2327 = h_copy_t_f4(fragColor)
	_2330 = h_mul_t_vf_f(swizzle_t_n4_xyz(_2327), 3.0)
	swizzle_set_t_n4_x(fragColor, swizzle_t_n3_x(_2330))
	swizzle_set_t_n4_y(fragColor, swizzle_t_n3_y(_2330))
	swizzle_set_t_n4_z(fragColor, swizzle_t_n3_z(_2330))
	param = swizzle_t_n4_xyz(fragColor)
	_2340 = tuple_get_retval((_call_ret_52 := ColorGrade_f3_arr(param), param := tuple_get_outparam(_call_ret_52, 1)))
	swizzle_set_t_n4_x(fragColor, swizzle_t_n3_x(_2340))
	swizzle_set_t_n4_y(fragColor, swizzle_t_n3_y(_2340))
	swizzle_set_t_n4_z(fragColor, swizzle_t_n3_z(_2340))
	param_1 = swizzle_t_n4_xyz(fragColor)
	_2350 = Tonemap_f3_arr(param_1)
	swizzle_set_t_n4_x(fragColor, swizzle_t_n3_x(_2350))
	swizzle_set_t_n4_y(fragColor, swizzle_t_n3_y(_2350))
	swizzle_set_t_n4_z(fragColor, swizzle_t_n3_z(_2350))
	return fragColor

def fillBufferA_f4_f2_arr(vFragColor, vFragCoord):
	global iResolution, iMouse
	vUV = h_div_t_vf_vf(vFragCoord, swizzle_n3_xy(iResolution))
	fAngle = h_mul_f_f(h_div_f_f(swizzle_n4_x(iMouse), swizzle_n3_x(iResolution)), 6.28318548)
	fElevation = h_mul_f_f(h_div_f_f(swizzle_n4_y(iMouse), swizzle_n3_y(iResolution)), 1.57079637)
	_vecif_47_exp = h_less_equal_than_n_n(swizzle_n4_x(iMouse), 0.0)
	if any_ifexp_true_n(_vecif_47_exp):
		_vecif_47_fAngle = fAngle
		_vecif_47_fElevation = fElevation
		_vecif_47_fAngle = -2.29999995
		_vecif_47_fElevation = 0.5
		fAngle = h_where_n_n_n(_vecif_47_exp, _vecif_47_fAngle, fAngle)
		fElevation = h_where_n_n_n(_vecif_47_exp, _vecif_47_fElevation, fElevation)
	fDist = 6.0
	cam = CameraState_defval()
	CameraState_vPos_set(cam, h_f3_n_n_n(h_mul_f_f(h_mul_f_f(h_sin_n(fAngle), 6.0), h_cos_n(fElevation)), h_mul_f_f(h_sin_n(fElevation), 6.0), h_mul_f_f(h_mul_f_f(h_cos_n(fAngle), 6.0), h_cos_n(fElevation))))
	CameraState_vTarget_set(cam, h_f3_n_n_n(0.0, 0.5, 0.0))
	CameraState_fFov_set(cam, 20.0)
	param = h_t_f3_defval(False)
	param_1 = h_t_f3_defval(False)
	tuple_get_retval((_call_ret_48 := Cam_GetCameraRay_f2_CameraState_f3_f3_arr(vUV, cam, h_t_f3_defval(False), h_t_f3_defval(False)), param := tuple_get_outparam(_call_ret_48, 0), param_1 := tuple_get_outparam(_call_ret_48, 1)))
	vRayOrigin = param
	vRayDir = param_1
	param_2 = 0.699999988
	param_3 = 2.0
	param_4 = 1.0
	fShade = GetVignetting_f2_f_f_f_arr(vUV, 0.699999988, 2.0, 1.0)
	param_5 = vRayOrigin
	param_6 = vRayDir
	param_7 = fShade
	vFragColor = MainCommon_f3_f3_f_arr(param_5, param_6, param_7)
	return vFragColor

vec_broadcast_count = 76800
_664 = [swizzle_n_xxx(0.0), swizzle_n_xxx(0.0), 0.0, -1.0, 1.0, -1, 0.0, swizzle_n_xxx(0.0), swizzle_n_xxx(1.0), -1, -1]
bufferA_iChannel2 = None
_bufferA_iChannel2_sampler = None
bufferA_iChannel3 = None
_bufferA_iChannel3_sampler = None
bufferA_iChannel1 = None
_bufferA_iChannel1_sampler = None
iChannel0 = None
_iChannel0_sampler = None
iChannel1 = None
_iChannel1_sampler = None
iChannel2 = None
_iChannel2_sampler = None
iChannel3 = None
_iChannel3_sampler = None
bufferA_iChannel0 = None
_bufferA_iChannel0_sampler = None
outColor = None
inCoord = None
g_vSunDir = h_f3_defval()
g_vSunColor = h_f3_defval()
g_vAmbientColor = h_f3_defval()
fPlaneInFocus = 0.0
fGolden = 0.0
iResolution = h_f3_defval()
iTime = 0.0
iMouse = h_f4_defval()
iTimeDelta = 0.0
iFrameRate = 0.0
iFrame = 0
iChannelTime = h_af_defval(4)
iChannelResolution = h_af3_defval(4)
iDate = h_f4_defval()
iSampleRate = 0.0


def frag_main():
	global g_vSunDir, g_vSunColor, g_vAmbientColor, fPlaneInFocus, fGolden
	g_vSunDir = h_f3_n_n_n(0.842151939, 0.336860776, 0.42107597)
	g_vSunColor = h_f3_n_n_n(5.0, 3.5, 2.5)
	g_vAmbientColor = h_f3_n_n_n(0.800000011, 0.200000003, 0.100000001)
	fPlaneInFocus = 5.0
	fGolden = 2.39996266

def shader_main(fc, fcd):
	global bufferA, g_bufferA_iChannel1, g_bufferA_iChannel2, g_bufferA_iChannel3, g_main_iChannel1, g_main_iChannel2, g_main_iChannel3, bufferA_iChannel0, bufferA_iChannel1, bufferA_iChannel2, bufferA_iChannel3, iChannel0, iChannel1, iChannel2, iChannel3, iChannelTime
	frag_main()
	iChannelTime[0] = iTime
	iChannelTime[1] = iTime
	iChannelTime[2] = iTime
	iChannelTime[3] = iTime

	bufferA_iChannel0 = bufferA
	set_channel_resolution(0, bufferA_iChannel0)
	bufferA_iChannel1 = g_bufferA_iChannel1
	set_channel_resolution(1, bufferA_iChannel1)
	bufferA_iChannel2 = g_bufferA_iChannel2
	set_channel_resolution(2, bufferA_iChannel2)
	bufferA_iChannel3 = g_bufferA_iChannel3
	set_channel_resolution(3, bufferA_iChannel3)
	bufferA = buffer_to_tex(fillBufferA_f4_f2_arr(fc, fcd))
	iChannel0 = bufferA
	set_channel_resolution(0, iChannel0)
	iChannel1 = g_main_iChannel1
	set_channel_resolution(1, iChannel1)
	iChannel2 = g_main_iChannel2
	set_channel_resolution(2, iChannel2)
	iChannel3 = g_main_iChannel3
	set_channel_resolution(3, iChannel3)
	return mainImage_f4_f2_arr(fc, fcd)

if __name__ == "__main__":
	g_show_with_opengl = True
	g_is_autodiff = False
	g_is_profiling = False
	g_is_full_vectorized = True
	g_face_color = "gray"
	g_win_zoom = 1
	g_win_size = None
	iResolution = torch.asarray([320, 240, 1])

	iMouse[0] = iResolution[0] * 0.5
	iMouse[1] = iResolution[1] * 0.5
	iMouse[2] = iResolution[0] * 0
	iMouse[3] = iResolution[1] * 0

	bufferA = init_buffer()
	g_bufferA_iChannel1 = load_tex_cube("shaderlib/texcube0.jpg")
	g_bufferA_iChannel2 = load_tex_2d("shaderlib/organic4.jpg")
	g_bufferA_iChannel3 = load_tex_2d("shaderlib/lichen.jpg")
	g_main_iChannel1 = load_tex_2d("shaderlib/stars.jpg")
	g_main_iChannel2 = load_tex_2d("shaderlib/stars.jpg")
	g_main_iChannel3 = load_tex_2d("shaderlib/font.png")
	if g_is_autodiff and g_is_profiling:
		profile_entry(main_entry_autodiff)
	elif g_is_autodiff:
		main_entry_autodiff()
	elif g_is_profiling:
		profile_entry(main_entry)
	else:
		main_entry()

