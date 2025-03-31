const axios = require("axios");
const FormData = require("form-data");
const fs = require("fs");

const PINATA_API_KEY = "your-pinata-api-key";
const PINATA_SECRET_API_KEY = "your-pinata-secret-key";

async function uploadMetadata() {
  const metadata = {
    name: "Titre de l'IP",
    description: "Description détaillée",
    image: "https://gateway.pinata.cloud/ipfs/<cid>",
    type: "image"
  };

  const jsonData = JSON.stringify(metadata);
  fs.writeFileSync("metadata.json", jsonData);

  const data = new FormData();
  data.append("file", fs.createReadStream("metadata.json"));

  try {
    const res = await axios.post("https://api.pinata.cloud/pinning/pinFileToIPFS", data, {
      headers: {
        "Content-Type": `multipart/form-data; boundary=${data._boundary}`,
        pinata_api_key: PINATA_API_KEY,
        pinata_secret_api_key: PINATA_SECRET_API_KEY,
      },
    });

    console.log(" Métadonnées uploadées avec succès :", res.data);
    return res.data.IpfsHash;
  } catch (error) {
    console.error("❌ Erreur lors de l'upload sur Pinata :", error);
  }
}

uploadMetadata();
