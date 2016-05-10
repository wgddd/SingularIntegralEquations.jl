export _₂F₁

const ρ = 0.72
immutable ℤ end

Base.in(n::Integer,::Type{ℤ}) = true
Base.in(n::Number,::Type{ℤ}) = n == round(Int,n)

abeqcd(a,b,cd) = a == b == cd
abeqcd(a,b,c,d) = (a == c && b == d)

absarg(z) = abs(angle(z))

sqrtatanhsqrt(x) = x == 0 ? one(x) : (s = sqrt(-x); atan(s)/s)
sqrtasinsqrt(x) = x == 0 ? one(x) : (s = sqrt(x); asin(s)/s)
sinnasinsqrt(n,x) = x == 0 ? one(x) : (s = sqrt(x); sin(n*asin(s))/(n*s))
cosnasinsqrt(n,x) = cos(n*asin(sqrt(x)))
expnlog1pcoshatanhsqrt(n,x) = x == 0 ? one(x) : (s = sqrt(x); (exp(n*log1p(s))+exp(n*log1p(-s)))/2)
expnlog1psinhatanhsqrt(n,x) = x == 0 ? one(x) : (s = sqrt(x); (exp(n*log1p(s))-exp(n*log1p(-s)))/(2n*s))

sqrtatanhsqrt(x::Real) = x == 0 ? one(x) : x > 0 ? (s = sqrt(x); atanh(s)/s) : (s = sqrt(-x); atan(s)/s)
sqrtasinsqrt(x::Real) = x == 0 ? one(x) : x > 0 ? (s = sqrt(x); asin(s)/s) : (s = sqrt(-x); asinh(s)/s)
sinnasinsqrt(n,x::Real) = x == 0 ? one(x) : x > 0 ? (s = sqrt(x); sin(n*asin(s))/(n*s)) : (s = sqrt(-x); sinh(n*asinh(s))/(n*s))
cosnasinsqrt(n,x::Real) = x > 0 ? cos(n*asin(sqrt(x))) : cosh(n*asinh(sqrt(-x)))
expnlog1pcoshatanhsqrt(n,x::Real) = x == 0 ? one(x) : x > 0 ? exp(n/2*log1p(-x))*cosh(n*atanh(sqrt(x))) : exp(n/2*log1p(-x))*cos(n*atan(sqrt(-x)))
expnlog1psinhatanhsqrt(n,x::Real) = x == 0 ? one(x) : x > 0 ? (s = sqrt(x); exp(n/2*log1p(-x))*sinh(n*atanh(s))/(n*s)) : (s = sqrt(-x); exp(n/2*log1p(-x))*sin(n*atan(s))/(n*s))

expm1nlog1p(n,x) = x == 0 ? one(x) : expm1(n*log1p(x))/(n*x)

speciallog(x) = x == 0 ? one(x) : x > 0 ? (s = sqrt(x); 3(atanh(s)-s)/s^3) : (s = sqrt(-x); 3(s-atan(s))/s^3)
function speciallog(x::Float64)
    if x > 0.2
        s = sqrt(x)
        3(atanh(s)-s)/s^3
    elseif x < -0.2
        s = sqrt(-x)
        3(s-atan(s))/s^3
    else
        speciallogseries(x)
    end
end
function speciallog(x::Complex128)
    if abs(x) > 0.2
        s = sqrt(-x)
        3(s-atan(s))/s^3
    else
        speciallogseries(x)
    end
end
# The Taylor series fails to be accurate to 1e-15 near x ≈ ±0.2. So we use a highly accurate Chebyshev expansion.
speciallogseries(x::Float64) = @clenshaw(5.0x,1.0087391788544393911192,1.220474262857857637288e-01,8.7957928919918696061703e-03,6.9050958578444820505037e-04,5.7037120050065804396306e-05,4.8731405131379353370205e-06,4.2648797509486828820613e-07,3.800372208946157617901e-08,3.434168059359993493634e-09,3.1381484326392473547608e-10,2.8939845618385022798906e-11,2.6892186934806386106143e-12,2.5150879096374730760324e-13,2.3652490233687788117887e-14,2.2349973917002118259929e-15,2.120769988408948118084e-16)
speciallogseries(x::Complex128) = @evalpoly(x,1.0000000000000000000000,5.9999999999999999999966e-01,4.2857142857142857142869e-01,3.3333333333333333333347e-01,2.7272727272727272727292e-01,2.3076923076923076923072e-01,1.9999999999999999999996e-01,1.7647058823529411764702e-01,1.5789473684210526315786e-01,1.4285714285714285714283e-01,1.3043478260869565217384e-01,1.2000000000000000000000e-01,1.1111111111111111111109e-01,1.0344827586206896551722e-01,9.6774193548387096774217e-02,9.0909090909090909090938e-02,8.5714285714285714285696e-02,8.1081081081081081081064e-02,7.6923076923076923076907e-02,7.3170731707317073170688e-02)

# The references to special cases are to Table of Integrals, Series, and Products, § 9.121, followed by NIST's DLMF.

"""
Compute the Gauss hypergeometric function `₂F₁(a,b;c;z)`.
"""
function _₂F₁(a::Real,b::Real,c::Real,z::Number)
    if a > b
        return _₂F₁(b,a,c,z) # ensure a ≤ b
    elseif a == c # 1. 15.4.6
        return exp(-b*log1p(-z))
    elseif b == c # 1. 15.4.6
        return exp(-a*log1p(-z))
    elseif c == 0.5
        if a+b == 0 # 31. 15.4.11 & 15.4.12
            return cosnasinsqrt(2b,z)
        elseif a+b == 1 # 32. 15.4.13 & 15.4.14
            return cosnasinsqrt(1-2b,z)*exp(-0.5log1p(-z))
        elseif b-a == 0.5 # 15.4.7 & 15.4.8
            return expnlog1pcoshatanhsqrt(-2a,z)
        end
    elseif c == 1.5
        if abeqcd(a,b,0.5) # 13. 15.4.4 & 15.4.5
            return sqrtasinsqrt(z)
        elseif abeqcd(a,b,1) # 14.
            return sqrtasinsqrt(z)*exp(-0.5log1p(-z))
        elseif abeqcd(a,b,0.5,1) # 15. 15.4.2 & 15.4.3
            return sqrtatanhsqrt(z)
        elseif a+b == 1 # 29. 15.4.15 & 15.4.16
            return sinnasinsqrt(1-2b,z)
        elseif a+b == 2 # 30.
            return sinnasinsqrt(2-2b,z)*exp(-0.5log1p(-z))
        elseif b-a == 0.5 # 4. 15.4.9 & 15.4.10
            return expnlog1psinhatanhsqrt(1-2a,z)
        end
    elseif c == 2
        if abeqcd(a,b,1) # 6. 15.4.1
            return (s = -z; log1p(s)/s)
        elseif a ∈ ℤ && b == 1 # 5.
            return expm1nlog1p(1-a,-z)
        elseif a == 1 && b ∈ ℤ # 5.
            return expm1nlog1p(1-b,-z)
        end
    elseif c == 2.5 && abeqcd(a,b,1,1.5)
         return speciallog(z)
    end
    _₂F₁general(a,b,c,z) # catch-all
end
_₂F₁{T}(a::Real,b::Real,c::Real,z::AbstractArray{T}) = reshape(promote_type(typeof(a),typeof(b),typeof(c),T)[ _₂F₁(a,b,c,z[i]) for i in eachindex(z) ], size(z))

function _₂F₁general{T}(a::Real,b::Real,c::Real,z::T)
    if abs(z) ≤ ρ
        w = z
        _₂F₁taylor(a,b,c,w)
    elseif abs(z/(z-1)) ≤ ρ # 15.8.1
        w = z/(z-1)
        _₂F₁taylor(a,c-b,c,w)*exp(-a*log1p(-z))
    elseif abs(1-z) ≤ ρ
        w = 1-z
        if c-a-b ∉ ℤ # 15.8.4
            gamma(c)*(gamma(c-a-b)/gamma(c-a)/gamma(c-b)*_₂F₁taylor(a,b,a+b-c+1,w)+exp((c-a-b)*log1p(-z))*gamma(a+b-c)/gamma(a)/gamma(b)*_₂F₁taylor(c-a,c-b,c-a-b+1,w))
        elseif c == a+b # 15.8.10
            gamma(a+b)/gamma(a)/gamma(b)*_₂F₁logsum(a,b,z,w)
        else
            zero(T) # TODO: full 15.8.10
        end
    elseif abs(z-0.5) > 0.5
        if a-b ∉ ℤ
            gamma(c)*(gamma(b-a)/gamma(b)/gamma(c-a)*(0.5-z)^(-a)*_₂F₁continuation(a,a+b,c,0.5,z) + gamma(a-b)/gamma(a)/gamma(c-b)*(0.5-z)^(-b)*_₂F₁continuation(b,a+b,c,0.5,z))
        elseif a == b # except c == a + 0.5 !
            gamma(c)/gamma(a)/gamma(c-a)*(0.5-z)^(-a)*_₂F₁continuationalt(a,c,0.5,z)
        else
            zero(T)
        end
    elseif abs(inv(z)) ≤ ρ && absarg(1-z) < convert(real(T),π) && absarg(z) < convert(real(T),π)
        w = inv(z)
        if a-b ∉ ℤ # 15.8.2
            gamma(c)*((-w)^a*gamma(b-a)/gamma(b)/gamma(c-a)*_₂F₁taylor(a,a-c+1,a-b+1,w)+(-w)^b*gamma(a-b)/gamma(a)/gamma(c-b)*_₂F₁taylor(b,b-c+1,b-a+1,w))
        elseif a == b # 15.8.8
            gamma(c)/gamma(a)/gamma(c-a)*(-w)^a*_₂F₁logsumalt(a,c,z)
        else
            zero(T) # TODO: full 15.8.8
        end
    elseif abs(inv(1-z)) ≤ ρ && absarg(1-z) < convert(real(T),π) && a-b ∉ ℤ # 15.8.3
        w = inv(1-z)
        gamma(c)*(exp(-a*log1p(-z))*gamma(b-a)/gamma(b)/gamma(c-a)*_₂F₁taylor(a,c-b,a-b+1,w)+exp(-b*log1p(-z))*gamma(a-b)/gamma(a)/gamma(c-b)*_₂F₁taylor(b,c-a,b-a+1,w))
        # TODO: 15.8.9
    elseif abs(1-inv(z)) ≤ ρ && absarg(1-z) < convert(real(T),π) && c-a-b ∉ ℤ # 15.8.5
        w = 1-inv(z)
        gamma(c)*(z^(-a)*gamma(c-a-b)/gamma(c-a)/gamma(c-b)*_₂F₁taylor(a,a-c+1,a+b-c+1,w)+z^(a-c)*(1-z)^(c-a-b)*gamma(a+b-c)/gamma(a)/gamma(b)*_₂F₁taylor(c-a,1-a,c-a-b+1,w))
        # TODO: 15.8.11
    else
        #throw(DomainError())
        zero(T)
    end
end

function _₂F₁taylor{T}(a::Real,b::Real,c::Real,z::T)
    S₀,S₁,err,j = one(T),one(T)+a*b*z/c,one(real(T)),1
    while err > 10eps2(T)
        rⱼ = (a+j)/(j+1)*(b+j)/(c+j)
        S₀,S₁ = S₁,S₁+(S₁-S₀)*rⱼ*z
        err = abs((S₁-S₀)/S₀)
        j+=1
    end
    return S₁
end

function _₂F₁tayloralt{T}(a::Real,b::Real,c::Real,z::T)
    C,S,err,j = one(T),one(T),one(real(T)),0
    while err > 10eps2(T)
        C *= (a+j)/(j+1)*(b+j)/(c+j)*z
        S += C
        err = abs(C/S)
        j+=1
    end
    return S
end

function _₂F₁continuation{T}(s::Real,t::Real,c::Real,z₀::Real,z::T)
    izz₀,d0,d1 = inv(z-z₀),one(T),s/(2s-t+one(T))*((s+1)*(1-2z₀)+(t+1)*z₀-c)
    S₀,S₁,izz₀j,err,j = one(T),one(T)+d1*izz₀,izz₀,one(real(T)),2
    while err > 10eps2(T)
        d0,d1,izz₀j = d1,(j+s-one(T))/j/(j+2s-t)*(((j+s)*(1-2z₀)+(t+1)*z₀-c)*d1 + z₀*(1-z₀)*(j+s-2)*d0),izz₀j*izz₀
        S₀,S₁ = S₁,S₁+d1*izz₀j
        err = abs((S₁-S₀)/S₀)
        j+=1
    end
    return S₁
end

function _₂F₁continuationalt{T}(a::Real,c::Real,z₀::Real,z::T)
    izz₀ = inv(z-z₀)
    e0,e1 = one(T),(a+one(T))*(one(T)-2z₀)+(2a+one(T))*z₀-c
    f0,f1 = zero(T),one(T)-2z₀
    cⱼ = log(z₀-z)+2digamma(one(T))-digamma(a)-digamma(c-a)
    S₀ = cⱼ
    cⱼ += 2/one(T)-one(T)/a
    C = a*izz₀
    S₁,err,j = S₀+(e1*cⱼ-f1)*C,one(real(T)),2
    while err > 10eps2(T)
        f0,f1 = f1,(((j+a)*(1-2z₀)+(2a+1)*z₀-c)*f1+z₀*(1-z₀)*(j-1)*f0+(1-2z₀)*e1+2z₀*(1-z₀)*e0)/j
        e0,e1 = e1,(((j+a)*(1-2z₀)+(2a+1)*z₀-c)*e1+z₀*(1-z₀)*(j-1)*e0)/j
        C *= (a+j-1)*izz₀/j
        cⱼ += 2/T(j)-one(T)/(a+j-one(T))
        S₀,S₁ = S₁,S₁+(e1*cⱼ-f1)*C
        err = abs((S₁-S₀)/S₀)
        j+=1
    end
    return S₁
end

function _₂F₁logsum{T}(a::Real,b::Real,z::T,w::T)
    cⱼ = 2digamma(one(T))-digamma(a)-digamma(b)-log1p(-z)
    C,S,err,j = one(T),cⱼ,one(real(T)),0
    while err > 10eps2(T)
        C *= (a+j)/(j+1)^2*(b+j)*w
        cⱼ += 2/(j+one(T))-one(T)/(a+j)-one(T)/(b+j)
        S += C*cⱼ
        err = abs(C/S)
        j+=1
    end
    return S
end

function _₂F₁logsumalt{T}(a::Real,c::Real,z::T)
    b,cⱼ = one(T)-c+a,log(-z)+2digamma(one(T))-digamma(a)-digamma(c-a)
    C,S,err,j = one(T),cⱼ,one(real(T)),0
    while err > 10eps2(T)
        C *= (a+j)/(j+1)^2*(b+j)/z
        cⱼ += 2/(j+one(T))-one(T)/(a+j)+one(T)/(c-a-(j+one(T)))
        S += C*cⱼ
        err = abs(C/S)
        j+=1
    end
    return S
end
