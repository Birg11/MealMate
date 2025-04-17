const express = require('express');
const stripe = require('stripe')('sk_live_...wUhq'); // Replace with your Stripe secret key
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Create a Payment Intent
app.post('/create-payment-intent', async (req, res) => {
    const { amount } = req.body; // Get the amount from the request

    try {
        const paymentIntent = await stripe.paymentIntents.create({
            amount,
            currency: 'usd', // Change this to your desired currency
        });

        res.status(200).send({
            clientSecret: paymentIntent.client_secret,
        });
    } catch (error) {
        res.status(500).send({ error: error.message });
    }
});

const PORT = process.env.PORT || 5000; // Use port 5000 or any available port
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
