require('util/sha1')

function secure_password(password_plain)
  local secret = 'F2IFM93HO7NKF268V4MW'
  return sha1(password_plain .. secret)
end
