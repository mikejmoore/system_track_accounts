require_relative '../spec_helper'
require 'digest'

describe "SSH Keys for User", :type => :api do
  let!(:super_user)  { FactoryGirl.create :super_user}
  let!(:normal_user)  { FactoryGirl.create :user}
  
  context "Add an SSH Key" do

    it "User can add own ssh public key" do
      
      credentials = sign_in(normal_user)
      
      public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDyH5n5Z2OdSkC+jpufYN0/4iixcM9cWZh3DtQLzhjZpIsixIITzY+dYmscM1ql7Yw/82Yqzzv0SxC8UDQnFLxvL1Cky+3jUA77P8CNnL/mc64oXPPSOsO12W0nIB6aGWakT6ygVN+SI1RLKoOgwWRXd2AB0r9MRNBrKq7cSCaWSNQcvWA0xBVNjXADshGTrd4abP/6/TKQAu21YRQjD8D8BtzL2peAcMG42uCJ/Odr/AbGX02Ov4rukNJ05DhX6QJtyJaVe85bq3Hx/SErIcIqlBfsED2CHcvMeY67cI2APW66btzsuAucxhVsbUumjwoaVVvSVn62ieAZ9s3RmwBb mike.moore@openlogic.com"
      ssh_key = {code: "first", public_key: public_key}
      params = {user_id: normal_user.id, credentials: credentials, ssh_key: ssh_key}
      response = post "/api/v1/users/add_ssh_key", params
      expect(response.status).to eq 200
      
      return_hash = JSON.parse(response.body)
      expect(return_hash['public_key']).to eq public_key
      
      public_key_hash = CryptUtils.sha_hash_hex(public_key)
      params = {public_key_hash: public_key_hash}
      response = get "/api/v1/users/find_ssh_key", params
      expect(response.status).to eq 200
      ssh_key_json = JSON.parse(response.body)
      expect(ssh_key_json['public_key']).to eq public_key
      expect(ssh_key_json['user']['email']).to eq normal_user.email
      expect(ssh_key_json['account']['id']).to eq normal_user.account.id
    end
    
    it "aes test" do
      # Now we do the actual setup of the cipher
      aes = OpenSSL::Cipher::Cipher.new(CryptUtils::ENCRYPTION_ALGORITHM)
      aes.encrypt
      #aes.key = key
      key = aes.random_key
      iv = aes.random_iv
#      aes.iv = iv

data = {
  aaaaa: "oahofdhaosdfhoashfdoahsodf asdf",
  bbbbb: "ohaosdfhaodfhoahsfoashdfosadhfoahoasodfhoashf",
  ccccc: {
    c1: "ohoahohdfohasdfa",
    c2: "oadsfasdfasdasdasdf",
    dddddd: {
      c1: "ohoahohdfohasdfa",
      c2: "oadsfasdfasdasdasdf"
    }
  }
}

      cipher = aes.update(data.to_json)
      cipher << aes.final

      puts "Our Encrypted data in base64"
      cipher64 = [cipher].pack('m')
      puts cipher64

      decode_cipher = OpenSSL::Cipher::Cipher.new(CryptUtils::ENCRYPTION_ALGORITHM)
      decode_cipher.decrypt
      decode_cipher.key = key
      decode_cipher.iv = iv
      plain = decode_cipher.update(cipher64.unpack('m')[0])
      plain << decode_cipher.final
      puts "Decrypted Text"
      puts plain
    end
    
    it "Can perform encryption of large data" do
      data = {
        aaaaa: "oahofdhaosdfhoashfdoahsodf asdf",
        bbbbb: "ohaosdfhaodfhoahsfoashdfosadhfoahoasodfhoashf",
        ccccc: {
          c1: "ohoahohdfohasdfa",
          c2: "oadsfasdfasdasdasdf",
          dddddd: {
            c1: "ohoahohdfohasdfa",
            c2: "oadsfasdfasdasdasdf"
          }
        }
      }
      
      
      data_and_key = CryptUtils.encrypt(data.to_json)
      encrypted_data64 = data_and_key[:encrypted_data]
      key64 = data_and_key[:key]
      iv64 = data_and_key[:iv]
      CryptUtils.decrypt(encrypted_data64, key64, iv64)
    end
    
  end
  
 
end