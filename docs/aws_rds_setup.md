# AWS RDS (MySQL) + VPC Foundation Setup

> ⚠️ **This is a reference document only — NOT yet integrated into the app.**

---

## 1. VPC Configuration

### Create a VPC
```
VPC Name:       pokemon-hau-vpc
IPv4 CIDR:      10.0.0.0/16
```

### Subnets (Minimum 2 AZs for RDS)
| Subnet           | CIDR Block     | AZ               | Type    |
|------------------|----------------|-------------------|---------|
| public-subnet-1  | 10.0.1.0/24    | ap-southeast-1a   | Public  |
| public-subnet-2  | 10.0.2.0/24    | ap-southeast-1b   | Public  |
| private-subnet-1 | 10.0.10.0/24   | ap-southeast-1a   | Private |
| private-subnet-2 | 10.0.11.0/24   | ap-southeast-1b   | Private |

### Internet Gateway
- Attach to `pokemon-hau-vpc`
- Route table for public subnets: `0.0.0.0/0 → igw-xxxxx`

### NAT Gateway (Optional for Lambda in private subnet)
- Deploy in `public-subnet-1`
- Route table for private subnets: `0.0.0.0/0 → nat-xxxxx`

### Security Groups
| SG Name             | Inbound Rule             | Source            |
|---------------------|--------------------------|-------------------|
| rds-sg              | MySQL/Aurora (3306)      | lambda-sg         |
| lambda-sg           | All traffic              | (self-reference)  |
| bastion-sg          | SSH (22)                 | Your IP           |

---

## 2. RDS MySQL Instance

### AWS Console / CLI Setup
```
Engine:             MySQL 8.0
Instance Class:     db.t3.micro (Free Tier)
DB Name:            pokemon_hau_db
Master Username:    admin
Master Password:    <your-secure-password>
VPC:                pokemon-hau-vpc
Subnet Group:       private-subnet-1, private-subnet-2
Security Group:     rds-sg
Public Access:      No
Storage:            20 GB (gp3)
Multi-AZ:           No (dev) / Yes (prod)
```

### Connection String Format
```
mysql://admin:<password>@<rds-endpoint>:3306/pokemon_hau_db
```

---

## 3. MySQL Tables (Mirror of Supabase Schema)

```sql
CREATE DATABASE IF NOT EXISTS pokemon_hau_db;
USE pokemon_hau_db;

CREATE TABLE profiles (
  id VARCHAR(36) PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  player_name VARCHAR(100),
  level INT DEFAULT 1,
  monster_caught_count INT DEFAULT 0,
  avatar_url TEXT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE caught_pokemon (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(36) NOT NULL,
  pokemon_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  sprite_url TEXT NOT NULL,
  caught_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE
);

CREATE INDEX idx_caught_user ON caught_pokemon(user_id);
CREATE INDEX idx_profiles_rank ON profiles(monster_caught_count DESC);
```

---

## 4. Environment Variables (To add to `.env` when ready)

```env
# AWS RDS
AWS_RDS_HOST=pokemon-hau-db.xxxxxxxxxx.ap-southeast-1.rds.amazonaws.com
AWS_RDS_PORT=3306
AWS_RDS_DATABASE=pokemon_hau_db
AWS_RDS_USERNAME=admin
AWS_RDS_PASSWORD=<your-secure-password>
```

---

## 5. Flutter Integration Notes (Future)

When ready to integrate, you would:

1. **Create a Lambda API Gateway** to act as a REST proxy between Flutter and RDS (Flutter should NOT connect directly to RDS).
2. **Lambda endpoints** needed:
   - `POST /auth/login` — Authenticate user
   - `POST /auth/register` — Create user + profile
   - `GET /profile/{userId}` — Fetch profile
   - `PUT /profile/{userId}` — Update profile
   - `POST /pokemon/catch` — Save caught pokemon
   - `GET /pokemon/{userId}` — Get user's collection
   - `GET /rankings` — Get leaderboard
   - `DELETE /account/{userId}` — Delete account
3. **In Dart**, use `http` package to call the Lambda API Gateway URL instead of direct DB access.

---

## 6. Architecture Diagram

```
Flutter App
    ↓ HTTPS
API Gateway (REST)
    ↓
Lambda Functions (Node.js/Python)
    ↓ MySQL Connection
RDS MySQL (Private Subnet)
    ↑
VPC (Security Groups)
```

---

## Status: 🔴 NOT INTEGRATED — Foundation Reference Only
