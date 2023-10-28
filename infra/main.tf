provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "abbasign" {
  name     = "abbasign"
  location = var.location
}
resource "azurerm_virtual_network" "abbasign" {
  name                = "abbasign-vn"
  location            = azurerm_resource_group.abbasign.location
  resource_group_name = azurerm_resource_group.abbasign.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "abbasign-DbSubnet" {
  name                 = "abbasign-DbSubnet"
  resource_group_name  = azurerm_resource_group.abbasign.name
  virtual_network_name = azurerm_virtual_network.abbasign.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "abbasign-AppSubnet" {
  name                 = "abbasign-AppSubnet"
  resource_group_name  = azurerm_resource_group.abbasign.name
  virtual_network_name = azurerm_virtual_network.abbasign.name
  address_prefixes     = ["10.0.3.0/24"]
  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}
resource "azurerm_private_dns_zone" "abbasign" {
  name                = "abbasignPrivDNS.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.abbasign.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "abbasign" {
  name                  = "abbasignVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.abbasign.name
  virtual_network_id    = azurerm_virtual_network.abbasign.id
  resource_group_name   = azurerm_resource_group.abbasign.name
}

resource "azurerm_postgresql_flexible_server" "abbasign" {
  name                   = "abbasign"
  resource_group_name    = azurerm_resource_group.abbasign.name
  location               = azurerm_resource_group.abbasign.location
  version                = "12"
  delegated_subnet_id    = azurerm_subnet.abbasign-DbSubnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.abbasign.id
  administrator_login    = "psqladmin"
  administrator_password = "psqlp4ss"

  storage_mb = 32768
  sku_name               = "B_Standard_B1ms"

  depends_on = [azurerm_private_dns_zone_virtual_network_link.abbasign]

}

resource "azurerm_postgresql_flexible_server_database" "abbasign" {
  name      = "abbasign"
  server_id = azurerm_postgresql_flexible_server.abbasign.id
  collation = "en_US.utf8"
  charset   = "utf8"
  depends_on = [
    azurerm_postgresql_flexible_server.abbasign
  ]  
}


# Create an Azure App Service Plan
resource "azurerm_service_plan" "abbasign" {
  name                = "abbasign"
  resource_group_name = azurerm_resource_group.abbasign.name
  location            = azurerm_resource_group.abbasign.location
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create an Azure Web App
resource "azurerm_linux_web_app" "abbasign" {
  name                = "abbasign"
  resource_group_name = azurerm_resource_group.abbasign.name
  location            = azurerm_service_plan.abbasign.location
  service_plan_id     = azurerm_service_plan.abbasign.id
  
  

  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT": "true"
  }
  
  site_config {
    application_stack{
      python_version = "3.10"
    }
  } 
  
}


resource "azurerm_app_service_virtual_network_swift_connection" "vnetintegrationconnection" {
  app_service_id  = azurerm_linux_web_app.abbasign.id
  subnet_id       = azurerm_subnet.abbasign-AppSubnet.id
}



