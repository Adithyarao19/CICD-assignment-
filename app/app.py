from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        "message": "Welcome to our Python Web App!",
        "version": "1.0.0",
        "environment": os.getenv('ENVIRONMENT', 'development')
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200

@app.route('/login', methods=['POST'])
def login():
    # This is a simplified login endpoint for demo purposes
    # In a real application, you would use proper authentication
    return jsonify({
        "message": "Login endpoint",
        "demo_account": {
            "email": "hire-me@anshumat.org",
            "password": "HireMe@2025!"
        }
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)